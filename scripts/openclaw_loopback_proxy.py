#!/usr/bin/env python3
import asyncio
import signal

LISTEN_HOST = "127.0.0.1"
LISTEN_PORT = 18789
TARGET_HOST = "100.75.58.42"
TARGET_PORT = 18789


async def pipe(reader: asyncio.StreamReader, writer: asyncio.StreamWriter) -> None:
    try:
        while True:
            data = await reader.read(65536)
            if not data:
                break
            writer.write(data)
            await writer.drain()
    finally:
        try:
            writer.close()
            await writer.wait_closed()
        except Exception:
            pass


async def handle_client(
    client_reader: asyncio.StreamReader, client_writer: asyncio.StreamWriter
) -> None:
    try:
        target_reader, target_writer = await asyncio.open_connection(TARGET_HOST, TARGET_PORT)
    except Exception:
        client_writer.close()
        await client_writer.wait_closed()
        return

    await asyncio.gather(
        pipe(client_reader, target_writer),
        pipe(target_reader, client_writer),
        return_exceptions=True,
    )


async def main() -> None:
    server = await asyncio.start_server(handle_client, LISTEN_HOST, LISTEN_PORT)
    stop_event = asyncio.Event()

    def stop() -> None:
        stop_event.set()

    loop = asyncio.get_running_loop()
    for sig in (signal.SIGINT, signal.SIGTERM):
        loop.add_signal_handler(sig, stop)

    async with server:
        await stop_event.wait()


if __name__ == "__main__":
    asyncio.run(main())
