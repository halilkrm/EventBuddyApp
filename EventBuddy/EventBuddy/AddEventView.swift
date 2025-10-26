//
//  AddEventView.swift
//  EventBuddy
//
//  Created by Halil Keremoğlu on 17.10.2025.
//

import SwiftUI

struct AddEventView: View {
    // Formdaki verileri tutacak değişkenler
    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var description: String = ""
    @State private var location: String = ""
    @State private var invitedEmails: String = ""
    
    //ViewModel' e erişim
    @ObservedObject var viewModel : EventListViewModel //Bu, ContentView ve AddEventView'in aynı beyni paylaşmasını sağlar.
    
    // Ekranı kapatır
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView{
            Form{
                Section(header: Text("Etkinlik Detayları")){
                    TextField("Etkinlik Başlığı",text:$title)
                    DatePicker("Tarih", selection: $date,displayedComponents: .date)
                    TextField("Konum",text: $location)
                }
                Section(header: Text("Açıklama")){
                    TextEditor(text: $description)
                        .frame(height: 150)
                }
                TextField("Davet edilecek e-postalar (virgülle ayırın)", text: $invitedEmails)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)       
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
            }
            .navigationTitle("Yeni Etkinlik")
                .navigationBarItems(
                    leading: Button("İptal"){
                        presentationMode.wrappedValue.dismiss()
                    },
                    trailing: Button("Kaydet"){
                        let address = Unmanaged.passUnretained(viewModel).toOpaque()
                                        print("...[AddEventView Kaydet] 'Kaydet'e basıldı. 'viewModel'in adresi: \(address)")
                        viewModel.addEvent(title: title, date: date, description: description, location: location,invitedEmailsString: invitedEmails)
                        presentationMode.wrappedValue.dismiss() //ekranı kapa
                    }
                        .disabled(title.isEmpty) //Baslık bossa kaydet pasif olsun
                )
                .onAppear {
                            let address = Unmanaged.passUnretained(viewModel).toOpaque()
                            print("[AddEventView .onAppear] 'AddEventView' ekrana geldi. Aldığı 'viewModel'in adresi: \(address)")
                        }
        }
    }
}

//#Preview {
  //  AddEventView(viewModel: EventListViewModel())
// }
