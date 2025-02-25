import Kingfisher
import SwiftUI

struct DownloadPreviewView: View {
    @ObservedObject var downloadItem: DownloadItem

    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: downloadItem.createdTime)
    }

    var body: some View {
        HStack(spacing: 8) {
            KFImage(URL(string: downloadItem.coverUrl))
                .placeholder {
                    Color.gray.opacity(0.2)
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 42, height: 42)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(downloadItem.title == "" ? "No Caption" : downloadItem.title)
                    .font(.system(.body, design: .rounded))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .bold()

                Group {
                    HStack(spacing: 2) {
                        Text("\(downloadItem.author)")
                    }
                    
                    Text("\(formattedDate)")
                }
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)

                if case .downloading(let progress) = downloadItem.status {
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(height: 4)
                        .padding(.top, 4)

                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            statusIcon
        }
    }

    var statusIcon: some View {
        switch downloadItem.status {
        case .pending:
            return Image(systemName: "clock")
                .foregroundColor(.orange)
                .frame(width: 24, height: 24)
        case .downloading:
            return Image(systemName: "arrow.down.circle")
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
        case .completed:
            return Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .frame(width: 24, height: 24)
        case .failed:
            return Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
                .frame(width: 24, height: 24)
        case .cancelled:
            return Image(systemName: "xmark.circle.fill")
                .foregroundColor(.gray)
                .frame(width: 24, height: 24)
        }
    }
}
