// Render every page of a PDF with CoreGraphics, the engine macOS Preview
// uses. Some print artifacts (transparency slabs, hairline seams between
// shapes that only touch) show only here, not in Typst's own PNG export.
//   swiftc -O scripts/preview.swift -o .build/preview-render
//   .build/preview-render <in.pdf> <out-dir> <scale>   → <out-dir>/NN.png
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let args = CommandLine.arguments
guard args.count >= 4, let doc = CGPDFDocument(URL(fileURLWithPath: args[1]) as CFURL),
      let scale = Double(args[3]) else {
  FileHandle.standardError.write("usage: preview-render <in.pdf> <out-dir> <scale>\n".data(using: .utf8)!)
  exit(2)
}
let outDir = args[2]
let pad = String(doc.numberOfPages).count
for i in 1...doc.numberOfPages {
  guard let page = doc.page(at: i) else { continue }
  let box = page.getBoxRect(.mediaBox)
  let w = Int((box.width * scale).rounded()), h = Int((box.height * scale).rounded())
  let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                      space: CGColorSpace(name: CGColorSpace.sRGB)!,
                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
  ctx.fill(CGRect(x: 0, y: 0, width: w, height: h))
  ctx.scaleBy(x: CGFloat(scale), y: CGFloat(scale))
  ctx.drawPDFPage(page)
  let name = String(repeating: "0", count: max(0, max(pad, 2) - String(i).count)) + String(i)
  let url = URL(fileURLWithPath: "\(outDir)/\(name).png") as CFURL
  let dest = CGImageDestinationCreateWithURL(url, UTType.png.identifier as CFString, 1, nil)!
  CGImageDestinationAddImage(dest, ctx.makeImage()!, nil)
  CGImageDestinationFinalize(dest)
}
