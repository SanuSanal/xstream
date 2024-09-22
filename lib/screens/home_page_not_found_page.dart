import 'dart:convert';

const String homePageNotConfigured = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Homepage Not Configured</title>
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background-color: #f7f9fc;
      color: #333;
      margin: 0;
      padding: 20px;
      height: 100vh;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      text-align: center; /* Center text for overall layout */
    }
    .content {
      max-width: 600px;
      background-color: white;
      border-radius: 15px;
      box-shadow: 0px 10px 25px rgba(0, 0, 0, 0.1);
      padding: 40px;
      width: 100%;
      flex-grow: 1;
    }
    h2 {
      color: #444;
      font-size: 32px;
      margin-bottom: 15px;
    }
    p {
      font-size: 18px;
      line-height: 1.6;
      color: #555;
      margin-bottom: 30px;
    }
    .step {
      margin-bottom: 20px;
      text-align: left;
      font-size: 17px;
      line-height: 1.8;
    }
    img {
      width: 17px;
      height: 17px;
      vertical-align: middle;
      margin: 0 5px;
    }
    .error-image {
      width: 100px; /* Specify width */
      height: auto; /* Maintain aspect ratio */
      margin-bottom: 20px;
    }
  </style>
</head>
<body>
  <div class="content">
    <!-- Page Not Configured Image -->
    <img src="https://img.icons8.com/clouds/100/000000/error.png" alt="Page Not Configured" class="error-image">

    <h2>Homepage Not Configured</h2>
    <p>It looks like your homepage hasn't been set up yet. Follow these steps to configure it:</p>

    <div class="step">
      <span>1. Open the <img src="https://img.icons8.com/ios-filled/50/000000/menu.png" alt="Drawer Icon"><strong>App Drawer</strong> from the top left corner.</span>
    </div>
    <div class="step">
      <span>2. Navigate to <img src="https://img.icons8.com/ios-filled/50/000000/settings.png" alt="Settings Icon"><strong>Settings</strong> to configure your homepage.</span>
    </div>
    <div class="step">
      <span>3. Add a stream site by tapping the <strong>+</strong> button.</span>
    </div>

    <p>Your chosen stream site will be displayed here once it’s set.</p>
  </div>
</body>
</html>
''';

String getHomePageNotConfiguredWebPage() {
  final String contentBase64 = base64Encode(
    const Utf8Encoder().convert(homePageNotConfigured),
  );
  return 'data:text/html;base64,$contentBase64';
}
