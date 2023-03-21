import Foundation
import NIO

final class MemcachedRequest {
    /// code goes here
}

final class MemcachedRequestDecoder: ByteToMessageDecoder {
    /// code goes here
}

final class MemcachedRequestEncoder: ByteToMessageEncoder {
    typealias OutboundIn = MemcachedRequest

    func encode(data: MemcachedRequest, out: inout ByteBuffer) throws {
        var buffer = out
        buffer.writeInteger(data.opcode.rawValue, endianness: .big)
        buffer.writeInteger(data.key.count, endianness: .big)
        buffer.writeInteger(data.expiration, endianness: .big)
        buffer.writeInteger(data.flags, endianness: .big)
        buffer.writeInteger(data.body.count, endianness: .big)
        buffer.writeBytes(data.key)
        buffer.writeBytes(data.body)
        out = buffer
    }
}

let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let bootstrap = ClientBootstrap(group: group)
    .channelInitializer { channel in
        let pipeline = channel.pipeline
        pipeline.addHandler(MemcachedRequestEncoder())
        pipeline.addHandler(MemcachedResponseDecoder())
        return channel.eventLoop.makeSucceededFuture(())
    }

let defaultHost = "::1"
let defaultPort = 8888

let channel = try bootstrap.bind(host: defaultHost, port: defaultPort).wait()

print("Server started and listening on \(channel.localAddress!)")

let request = MemcachedRequest(opcode: .set, key: "key", expiration: 0, flags: 0, body: "value".utf8)
channel.write(request, promise: nil)
