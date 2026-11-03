# Halloween mode for your Mac

[中文](README.zh-CN.md)

Point your Mac's camera at the door. Whoever walks in gets a skeleton and a
greeting read aloud. Children and pets get a cute one that hops and waves a
lollipop. Grown-ups get a scary one that lunges at the screen.

Everything runs on your Mac. A local vision model, served by
[tempo9](https://github.com/thinkspread/tempo9), does the looking. No
frame leaves the machine.

## Install

```bash
brew install thinkspread/tap/tempo9
brew install thinkspread/tap/halloween
```

## Run

```bash
halloween
```

The first run downloads Qwen3.5-9B (Q4_K_S) and its vision encoder, about
6.4 GB. Later runs start in seconds. Your browser then opens
`http://127.0.0.1:1031`. Press **🎃 Start** and allow the camera.

| When the camera sees… | It says… | Skeleton |
|---|---|---|
| a child in a Halloween costume | Trick or treat! Great costume. Take two candies. | cute |
| a child | Hi there! Happy Halloween, little one. | cute |
| an adult in a costume | Nice costume... but I am scarier. Happy Halloween! | scary |
| an adult | Boo! Got you. Happy Halloween! | scary |
| a dog or a cat | A furry visitor. No candy for you. | cute |

Each visitor gets one scare. Step out of view and walk back in for another.
Whoever is in view when you press Start gets the first one.

The page follows the browser's language, English or Chinese. A button in the
corner switches it before you press Start, and hides once you do, so it stays
out of any recording.

There is nothing to set up. If tempo9 is already running with a vision
encoder, `halloween` uses it. Otherwise it starts one, and stops it again
when you press Ctrl-C.

## How it decides when to look

A vision model takes a couple of seconds per frame, so the page does not ask
it about every frame:

1. Once a second, the page compares a 32×18 thumbnail with the last frame
   it measured. An unchanged picture stops here.
2. A changed picture goes to tempo9's vision encoder only (not the language
   model), which returns one vector per region of the frame. The page
   measures how far the most-changed region has moved.
3. The model is asked "which of these is in the picture?" only when that
   distance crosses a threshold set from the camera's own noise.

## Privacy

The page may only connect to the server that served it
(`Content-Security-Policy: connect-src 'self'`). That server is `halloween`
on `127.0.0.1`, which passes three calls to tempo9 on `127.0.0.1` and
nothing else. The skeletons are drawn in the page, the sounds are
synthesised, and the voices are the Mac's own. The network is used only
to download tempo9's model and encoder on the first run.

## Requirements

- An Apple Silicon Mac with macOS 26 (tempo9's requirement)
- tempo9 1.3.0 or newer
- About 6.4 GB of disk for the model and encoder

Tested on an M5 Pro MacBook Pro with 24 GB.

## Options

```
halloween [--port 1031] [--server http://127.0.0.1:11435] [--no-open]
```

- `--port` is where the page is served.
- `--server` points at a tempo9 that is already running, for example one
  you started yourself with another model and `--tower auto`.

## License

Apache-2.0. See [LICENSE](LICENSE).
