<div align="center">
<img src="img/preview.png" alt="Application preview showing search result"/>
<h1>Yatta ヤッタ</h1>

[![Made with Fluent Design](https://img.shields.io/badge/fluent-design-blue?labelColor=0078D7")](https://github.com/bdlukaa/fluent_ui "Made with Fluent Design")
[![Discord](https://img.shields.io/discord/1018012382557126676)](https://discord.gg/QR63QRZntK "Discord")

<em>An on-demand videos client for searching, browsing, managing videos from your favorite on-demand video platforms.</em>
</br>

</div>

> [!WARNING]  
> This application is currently under development, changes on application behavior is expected without notice nor migration guide.

## Features

- Search videos from your favorite platform (YouTube, Peertube, etc) 🔎
- Video playlist (history, saved, etc) 🗃️
- Plain text database for easy scripting 📃
- Modal navigation for keyboard user 🇭 🇯 🇰 🇱
- Middle click autoscrolling, just like web browsers 🖱️

## Supported video platforms

- YouTube (via [YouTube Data API](https://developers.google.com/youtube/v3))

## User guide

### YouTube API key

Read the guide [here](https://developers.google.com/youtube/v3/getting-started). Once you obtain the API key, go to `Settings > YouTube API Settings > API key` and add the API key.

> [!NOTE]  
> This API key will be good daily personal usage. For detailed breakdown on how YouTube Data API quota is calculated, read [ YouTube Data API (v3) - Quota Calculator](https://developers.google.com/youtube/v3/determine_quota_cost). You can adjust how the app consume this quota in `Settings > YouTube API Settings` by disabling/limiting few features.

### Playing videos

Example below shows a guide to play video from Chromium web browser:

Go to `Setting > Video play command`, edit the command to:

```
chromium $url
```

You can also add extra command to run after the other command by pressing `Add more` button. For example you can add notification:

```
chromium $url
```

```
notify-send Playing video $title\n$description
```

Available variable to use includes:

| Name          | Description                                                  | Example                                                                                                                      |
| ------------- | ------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------- |
| `url`         | -                                                            | `https://www.youtube.com/watch?v=qWNQUvIk954`                                                                                |
| `title`       | -                                                            | `Rick Astley - Never Gonna Stop (Official Video)`                                                                            |
| `description` | -                                                            | `Never Gonna Stop (Official Video) Listen here: https://rickastley.lnk.to/NeverGonnaStopID The new album 'Are We There Yet?` |
| `type`        | Object type (possible value: `video`, `channel`, `playlist`) | `video`                                                                                                                      |
| `preview`     | Large size image                                             | `https://i.ytimg.com/vi/qWNQUvIk954/hqdefault.jpg`                                                                           |
| `thumbnail`   | Medium size image                                            | `https://i.ytimg.com/vi/qWNQUvIk954/mqdefault.jpg`                                                                           |
| `icon`        | Small size image                                             | `https://i.ytimg.com/vi/qWNQUvIk954/default.jpg`                                                                             |

## Building from source

This program is written using Flutter. For installation guide, please refer to [official Flutter's setup guide](https://docs.flutter.dev/get-started/install/linux/desktop). No additional build dependencies required beside the dependencies required by Flutter.

If you have a problem when building, check `pubspec.lock` file to find compatible Flutter SDK version to use, for example the snippet below indicating Flutter SDK version `3.19.X`:

```
sdks:
  dart: ">=3.3.0 <4.0.0"
  flutter: ">=3.19.0"
```

## Contributing

<details>
<summary><strong>How do I add support for a new platform?</strong></summary>
First please confirm the platform you are adding has an official search API support, otherwise your request will be rejected. Other than that, piracy sites will also be rejected.
</details>

## License

[GNU General Public License, version 3](./LICENSE)
