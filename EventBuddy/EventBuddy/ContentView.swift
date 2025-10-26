//
//  ContentView.swift
//  EventBuddy
//
//  Created by Halil Keremoğlu on 14.10.2025.
//
import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @StateObject private var vm : EventListViewModel
    
    //MainView'den gelen kullanıcı oturum bilgisi
    let userSession: User
    
    @State private var showingAddEventView = false
    
    init(userSession: User) {
        self.userSession = userSession
        
        let newVM = EventListViewModel(user: userSession)
        _vm = StateObject(wrappedValue: newVM)
        
        let address = Unmanaged.passUnretained(newVM).toOpaque()
        print("[ContentView init] 'ContentView' yaratıldı. 'Beyin' (Adres: \(address)) yaratıldı ve 'vm'ye atandı.")
    }
    
    var body: some View {
            NavigationView {
                
                List {
                    
                    Section(header: Text("Davetiyeler (\(vm.pendingEvents.count))")) {
                        
                        // 'pendingEvents' dizisi boşsa bir mesaj göster
                        if vm.pendingEvents.isEmpty {
                            Text("Yeni davetiyeniz yok.")
                                .foregroundColor(.secondary)
                        }
                        
                        ForEach(vm.pendingEvents) { event in
                            // Davetiye satırı için özel bir görünüm
                            PendingEventRow(event: event, viewModel: vm)
                        }
                    }
                    
                    Section(header: Text("Etkinliklerim (\(vm.events.count))")) {
                        
                        if vm.events.isEmpty {
                            Text("Görüntülenecek etkinliğiniz yok.")
                                .foregroundColor(.secondary)
                        }
                        
                        ForEach(vm.events) { event in
                            EventRowView(event: event)
                            
                            // Sola kaydırarak silme
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                
                                // Güvenlik kontrolünü 'participants' haritasına göre yap
                                if event.participants[vm.currentUserID ?? ""] == "owner" {
                                    Button(role: .destructive) {
                                        vm.deleteEvent(event: event)
                                    } label: {
                                        Label("Sil", systemImage: "trash.fill")
                                    }
                                }
                            }
                            // Stil kodları
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                        }
                    }
                }
                .listStyle(.grouped)
                .background(Color.appBackground)
                .navigationTitle("Etkinliklerim")
                .navigationBarItems(
                    leading: Button("Çıkış Yap") { vm.signOut() },
                    trailing: Button(action: { showingAddEventView = true }) {
                        Image(systemName: "plus")
                    }
                )
                .sheet(isPresented: $showingAddEventView) {
                    AddEventView(viewModel: vm)
                }
                
            } // NavigationView biter
        } // body biter
}

// Preview bloğu 'init(user: User)' nedeniyle hata verir,
// burayı yorumda bırakmak daha mantıklı
// #Preview {
//     ContentView()
// }
