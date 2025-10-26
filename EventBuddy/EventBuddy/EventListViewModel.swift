
import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Combine

class EventListViewModel: ObservableObject {
    
    @Published var events = [Event]()
    private let db = Firestore.firestore()
    

    private var myEventsListener: ListenerRegistration?
    private var invitedEventsListener: ListenerRegistration?
    private var pendingEventsListener: ListenerRegistration?
    
     var currentUserID: String?
    private var currentUserEmail: String?

    // Sonuçları ayrı ayrı tutmak için
    private var myEvents: [Event] = []
    private var invitedToEvents: [Event] = []
    @Published var pendingEvents: [Event] = []


    init(user: User) {
            print("[ViewModel] init çağrıldı. Kullanıcı: \(user.uid)")
            
            //Kullanıcı bilgilerini anında ayarla
            self.currentUserID = user.uid
            self.currentUserEmail = user.email ?? ""
            
            //Veri çekmeyi anında başlat
            fetchEvent()
        }
    
    init() {
        let address = Unmanaged.passUnretained(self).toOpaque()
        print("[VM INIT-Boş] 'Boş Beyin' (Preview için) yaratıldı. Adres: \(address)")
    }
        
        private func parseEvents(from snapshot: QuerySnapshot) -> [Event] {
            return snapshot.documents.compactMap { doc -> Event? in
                let data = doc.data()
                
                let id = doc.documentID
                let title = data["title"] as? String ?? ""
                let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
                let description = data["description"] as? String ?? ""
                let location = data["location"] as? String ?? ""
                let createdById = data["createdById"] as? String ?? ""
                
                // 'participants' haritasını da çek
                let participants = data["participants"] as? [String: String] ?? [:]
                
                return Event(
                    id: id,
                    title: title,
                    date: date,
                    description: description,
                    location: location,
                    createdById: createdById,
                    participants: participants // <-- YENİ
                )
            }
        }
    private func mergeAndPublishEvents() {
        // İki listeyi birleştir
        let allEvents = myEvents + invitedToEvents

        // Örn: Hem oluşturucusu hem davetlisi isem (ki bu mümkün),
        // etkinlik listede iki kez görünmesin.
        var uniqueEvents = [String: Event]()
        for event in allEvents {
            uniqueEvents[event.id ?? "1"] = event
        }

        // Sözlükteki değerleri alıp, tarihe göre sırala
        self.events = Array(uniqueEvents.values).sorted { $0.date < $1.date }

        print("...[ViewModel] Listeler birleştirildi. Toplam \(self.events.count) benzersiz etkinlik var.")
    }
    
        
        private func fetchEvent() {
            
            guard let userID = self.currentUserID else {
                 print(" HATA: fetchEvent, kullanıcı ID'si olmadan çağrıldı.")
                return
            }
            
            print(" [ViewModel] fetchEvent (v3) çalışıyor. 3 dinleyici kuruluyor...")
            
            stopListening() // Önceki tüm dinleyicileri durdur
            
            // Dinleyici: Sahibi olduğum etkinlikler ("owner")
            myEventsListener = db.collection("events")
                .whereField("participants.\(userID)", isEqualTo: "owner")
                .addSnapshotListener { snapshot, error in
                    
                    if let error = error { print("HATA (Owner): \(error)"); return }
                    guard let snapshot = snapshot else { return }
                    
                    print(" [VM] Dinleyici 1 (Owner) çalıştı: \(snapshot.documents.count) adet.")
                    self.myEvents = self.parseEvents(from: snapshot)
                    self.mergeAndPublishEvents() // Ana listeyi birleştir
                }
            
            // Dinleyici: Kabul ettiğim etkinlikler ("accepted")
            invitedEventsListener = db.collection("events")
                .whereField("participants.\(userID)", isEqualTo: "accepted")
                .addSnapshotListener { snapshot, error in
                    
                    if let error = error { print(" HATA (Accepted): \(error)"); return }
                    guard let snapshot = snapshot else { return }

                    print(" [VM] Dinleyici 2 (Accepted) çalıştı: \(snapshot.documents.count) adet.")
                    self.invitedToEvents = self.parseEvents(from: snapshot)
                    self.mergeAndPublishEvents() // Ana listeyi birleştir
                }

            // Dinleyici: Beklemede olan davetiyeler ("pending")
            pendingEventsListener = db.collection("events")
                .whereField("participants.\(userID)", isEqualTo: "pending")
                .addSnapshotListener { snapshot, error in
                    
                    if let error = error { print("HATA (Pending): \(error)"); return }
                    guard let snapshot = snapshot else { return }

                    print("[VM] Dinleyici 3 (Pending) çalıştı: \(snapshot.documents.count) adet.")
                    // Bu listeyi BİRLEŞTİRMİYORUZ, ayrı olarak yayınlıyoruz.
                    self.pendingEvents = self.parseEvents(from: snapshot).sorted { $0.date < $1.date }
                }
        }
    
    
        
        func addEvent(title: String, date: Date, description: String, location: String, invitedEmailsString: String) {
            
            guard let userID = self.currentUserID else {
                print(" HATA: addEvent BAŞARISIZ. 'currentUserID' boş.")
                return
            }
            
            //  Gelen e-posta metnini temiz bir diziye çevir
            let emailsToInvite = invitedEmailsString
                .split(separator: ",")
                .map { String($0.trimmingCharacters(in: .whitespaces)) }
                .filter { !$0.isEmpty && $0.contains("@") }
            
            print("...[addEvent] E-postalar alındı: \(emailsToInvite)")
            
            // Bu e-postaları UID'lere dönüştürmek için YARDIMCI fonksiyonu çağır
            findUIDs(for: emailsToInvite) { invitedUIDs in
                
                print("...[addEvent] UID'ler bulundu: \(invitedUIDs)")
                
                //'participants' haritasını oluştur
                var participantsMap: [String: String] = [:]
                
                //Kendini "sahip" (owner) olarak ekle
                participantsMap[userID] = "owner"
                
                //Davetlileri "beklemede" (pending) olarak ekle
                for uid in invitedUIDs {
                    if uid != userID { // Kendini tekrar ekleme
                        participantsMap[uid] = "pending"
                    }
                }
                
                print("...[addEvent] 'participants' haritası oluşturuldu: \(participantsMap)")
                
                // Yeni veri modelini Firestore'a kaydet
                let newEventData: [String: Any] = [
                    "title": title,
                    "date": Timestamp(date: date),
                    "description": description,
                    "location": location,
                    "createdById": userID,
                    "participants": participantsMap
                ]
                
                self.db.collection("events").addDocument(data: newEventData) { error in
                    if let error = error {
                        print(" HATA: 'addEvent' Firestore KAYIT HATASI: \(error.localizedDescription)")
                    } else {
                        print("BAŞARILI: 'addEvent' (v2) veriyi kaydetti.")
                    }
                }
            }
        }

        
        private func findUIDs(for emails: [String], completion: @escaping ([String]) -> Void) {
            
            if emails.isEmpty {
                print("...[findUIDs] E-posta listesi boş geldi. Boş dizi döndürülüyor.")
                completion([])
                return
            }
            
            print("...[findUIDs] 'users' koleksiyonunda şu e-postalar aranıyor (küçük harfli): \(emails)")
            
            var foundUIDs: [String] = []
            let group = DispatchGroup() // Tüm aramaların bitmesini beklemek için
            
            group.enter() // Arama başlıyor
            
            // Firestore 'where "in"' sorgusu 10 e-posta ile sınırlıdır, şimdilik bu OK.
            db.collection("users").whereField("email", in: emails).getDocuments { snapshot, error in
                
                // Firestore sorgusunda bir hata oldu mu?
                if let error = error {
                    print(" HATA: [findUIDs] Firestore SORGUSU BAŞARISIZ OLDU: \(error.localizedDescription)")
                    print(" [findUIDs] Bu hata, 'users' koleksiyonundaki 'email' alanı için bir 'index' (dizin) gerekebileceği anlamına gelebilir.")
                }
                
                if let snapshot = snapshot {
                    //Sorgu çalıştıysa kaç adet eşleşme bulundu?
                    print("...[findUIDs] Sorgu tamamlandı. \(snapshot.documents.count) adet eşleşen kullanıcı bulundu.")
                    
                    foundUIDs = snapshot.documents.compactMap { doc -> String? in
                        let data = doc.data()
                        let uid = data["uid"] as? String
                        let email = data["email"] as? String
                        print("...[findUIDs] Eşleşme bulundu: email: \(email ?? "yok"), uid: \(uid ?? "yok")")
                        return uid
                    }
                } else if error == nil {
                    print("...[findUIDs] Sorgu tamamlandı. Snapshot 'nil' geldi (hiçbir şey bulunamadı).")
                }
                
                group.leave() // Arama bitti
            }
            
            // Tüm aramalar bittiğinde...
            group.notify(queue: .main) {
                print("...[findUIDs] Arama tamamlandı. Bulunan UID'ler (completion): \(foundUIDs)")
                completion(foundUIDs)
            }
        }
    
    
        
        func deleteEvent(event: Event) {
            
            guard let eventID = event.id else {
                print(" HATA: Silme hatası. Event ID boş.")
                return
            }
            guard let userID = self.currentUserID else {
                print(" HATA: Silme hatası. User ID boş.")
                return
            }
            
            // GÜVENLİK KONTROLÜ DEĞİŞTİ:
            guard event.participants[userID] == "owner" else {
                print("❌ HATA: Bu etkinliği silme yetkiniz yok (Sahibi değilsiniz).")
                return
            }
            
            print("...[deleteEvent] Etkinlik siliniyor: \(eventID)")
            db.collection("events").document(eventID).delete() { error in
                if let error = error {
                    print(" HATA: Silme işlemi Firestore'da başarısız oldu: \(error.localizedDescription)")
                } else {
                    print(" BAŞARILI: Etkinlik silindi.")
                }
            }
        }
    
        func acceptInvite(event: Event) {
            guard let userID = self.currentUserID, let eventID = event.id else { return }

            print("...[acceptInvite] Davet kabul ediliyor: \(eventID)")
            
            // Firestore'daki 'participants' haritasını güncelle
            // Durumu "pending" -> "accepted" yap
            db.collection("events").document(eventID).updateData([
                "participants.\(userID)": "accepted"
            ]) { error in
                if let error = error {
                    print(" HATA: Davet kabul edilemedi: \(error.localizedDescription)")
                } else {
                    print(" BAŞARILI: Davet kabul edildi.")
                }
            }
            // Not: addSnapshotListener değişikliği otomatik algılayıp
            // etkinliği 'pendingEvents' listesinden 'events' listesine taşıyacaktır.
        }

        
        func rejectInvite(event: Event) {
            guard let userID = self.currentUserID, let eventID = event.id else { return }
            
            print("...[rejectInvite] Davet reddediliyor: \(eventID)")

            // Durumu "pending" -> "rejected" yap
            db.collection("events").document(eventID).updateData([
                "participants.\(userID)": "rejected"
            ]) { error in
                if let error = error {
                    print(" HATA: Davet reddedilemedi: \(error.localizedDescription)")
                } else {
                    print(" BAŞARILI: Davet reddedildi.")
                }
            }
            // Not: addSnapshotListener değişikliği otomatik algılayıp
            // etkinliği 'pendingEvents' listesinden kaldıracaktır.
        }
    
    
    
    
    
    
    func signOut() {
        print("...[ViewModel] signOut çağrıldı.")
        
        // Önce dinleyicileri ve verileri temizle
        stopListening()
        
        // ŞİMDİ kullanıcı bilgilerini de manuel olarak temizle
        self.currentUserID = nil
        self.currentUserEmail = nil
        
        //  Firebase'den çıkış yap
        do {
            try Auth.auth().signOut()
            print("[ViewModel] Kullanıcı çıkışı başarılı.")
        } catch let signOutError as NSError {
            print(" [ViewModel] signOut HATASI: %@", signOutError)
        }
    }
    


        func stopListening() {
            print("...[ViewModel] stopListening çağrıldı. 3 dinleyici de durduruluyor.")
            
            myEventsListener?.remove()
            myEventsListener = nil
            
            invitedEventsListener?.remove()
            invitedEventsListener = nil
            
            pendingEventsListener?.remove()
            pendingEventsListener = nil
            
            // Tüm dizileri temizle
            self.events = []
            self.pendingEvents = [] 
            self.myEvents = []
            self.invitedToEvents = []
        }
}
