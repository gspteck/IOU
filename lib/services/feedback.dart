import 'dart:io';
import 'dart:typed_data';

import 'package:feedback/feedback.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class FeedbackServices {
	sendFeedback(context) async {
		BetterFeedback.of(context).show((feedback) async {
			// draft an email and send to developer
			final screenshotFilePath =
			await writeImageToStorage(feedback.screenshot);

			final Email email = Email(
				body: feedback.text,
				subject: 'App Feedback',
				recipients: ['gspteck@gmail.com'],
				attachmentPaths: [screenshotFilePath],
				isHTML: false,
			);
			await FlutterEmailSender.send(email);
		});
	}

	Future<String> writeImageToStorage(Uint8List feedbackScreenshot) async {
  	final Directory output = await getTemporaryDirectory();
  	final String screenshotFilePath = '${output.path}/feedback.png';
  	final File screenshotFile = File(screenshotFilePath);
  	await screenshotFile.writeAsBytes(feedbackScreenshot);
  	return screenshotFilePath;
	}
}
