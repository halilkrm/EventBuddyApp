//
//  EventRowView.swift
//  EventBuddy
//
//  Created by Halil Keremoğlu on 21.10.2025.
//

import SwiftUI

struct EventRowView: View {
    let event:  Event
    var body: some View {
        HStack(spacing:15){
            VStack{
                Text(event.date.formatted(.dateTime.month(.abbreviated)))
                    .font(.caption.weight(.bold))
                    .foregroundColor(Color.appPrimary)
                Text(event.date.formatted(.dateTime.day()))
                    .font(.title2.weight(.bold))
                    .foregroundColor(Color.appText)
            }
            .frame(width:60,height: 60)
            .background(Color.white)
            .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4){
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(Color.appText)
                Text(event.location)
                    .font(.subheadline)
                    .foregroundColor(Color.appSecondary)
                
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1),radius: 5,x:0,y:2)
    }
}

 //#Preview {
   // EventRowView(event: Event)
//}
