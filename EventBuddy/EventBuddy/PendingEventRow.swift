//
//  PendingEventRow.swift
//  EventBuddy
//
//  Created by Halil Keremoğlu on 26.10.2025.
//

import SwiftUI

struct PendingEventRow: View {
    
    let event: Event
    @ObservedObject var viewModel: EventListViewModel // 'accept'/'reject' için
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.headline)
                Text(event.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(event.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 10) {
                Button(action: {
                    // ViewModel'deki fonksiyonu çağır
                    viewModel.acceptInvite(event: event)
                }) {
                    Text("Kabul Et")
                        .font(.caption.weight(.bold))
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    // ViewModel'deki fonksiyonu çağır
                    viewModel.rejectInvite(event: event)
                }) {
                    Text("Reddet")
                        .font(.caption.weight(.bold))
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .buttonStyle(.plain) // Butonların tüm satıra basmasını engeller
        }
        .padding(.vertical, 5) 
    }
}
