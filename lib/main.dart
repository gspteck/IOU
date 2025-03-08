// dart packages
import 'dart:async';
import 'dart:convert';

// flutter packages
import 'package:flutter/material.dart';

// third-party packages
import 'package:intl/intl.dart';
import 'package:feedback/feedback.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// project packages
import 'package:iou/colors.dart';

import 'package:iou/elements/add_button.dart';
import 'package:iou/elements/money_box.dart';
import 'package:iou/elements/transaction_box.dart';

import 'package:iou/services/feedback.dart';
import 'package:iou/services/appodeal.dart';

void main() async {
 	runApp(
    BetterFeedback(
      child: const MyApp(),
    ),
  ); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
	final numberFormat = NumberFormat("###,###,###.##", "tr_TR"); 

	TextEditingController usernameTextEditingController = TextEditingController();
	String username = "John Doe";
	bool editingUsername = false;

	double totalOwed = 0;
	String totalOwedInt = "";
	String totalOwedDec = "";

	Map<String, dynamic> moneyData = {
  	"data": [],
	};
	Map<String, dynamic> transactionData = {
		"data": [],
	};
	

	@override
	void initState() {	
		super.initState();

		AppodealServices as = AppodealServices();
		as.init();

		loadData();
		Timer.periodic(const Duration(milliseconds: 300), (t) async {
			loadData();
		});
	}

	@override
	void dispose() {
		usernameTextEditingController.text;
		super.dispose();
	}

  @override
  Widget build(BuildContext context) {
		final topPaddingHeight = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenAvrg = (screenWidth/9 + screenHeight/16)/2;

    return Scaffold(
			backgroundColor: mainColor,
      body: Center(
        child: SingleChildScrollView(
    			child: Column(children: [
						// Top White Section
						Container(
							width: screenWidth,
							height: screenHeight * 0.4,
							decoration: BoxDecoration(
								color: backgroundColor,
								borderRadius: BorderRadius.only(
									bottomLeft: Radius.circular(35),
									bottomRight: Radius.circular(35),
								),
							),
							child: Column(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									Padding(padding: EdgeInsets.only(bottom: topPaddingHeight + screenHeight * 0.04)),
									Row(children: [
										Padding(padding: EdgeInsets.only(right: screenWidth * 0.1)),
										!editingUsername
											? Text(
												"Hi, $username.",
												style: GoogleFonts.bebasNeue(
													fontSize: 
													20,
													fontWeight: FontWeight.bold,
												),
											)
											: SizedBox(
												width: screenWidth * 0.4,
												child: TextField(
													controller: usernameTextEditingController,	
													decoration: InputDecoration(
														hintText: "Username",
														hintStyle: GoogleFonts.bebasNeue(color: whiteTextColor),
													),
												),
											), 
									  IconButton(
											onPressed: () {
												if (!editingUsername) {
													setState(() {
														editingUsername = true;
													});
												} else {
													editUsername();	
												}
											},
											icon: Icon(
											 !editingUsername ?	Icons.edit : Icons.check,
												size: 15,
												color: darkTextColor,
											),
										),	
										const Spacer(),
										IconButton(
											onPressed: () {
												FeedbackServices fs = FeedbackServices();
												fs.sendFeedback(context);																		},
											icon: Icon(
												Icons.bug_report,	
												color: darkTextColor,
											),
										),
										Padding(padding: EdgeInsets.only(left: screenWidth * 0.07)),
									]),

									Padding(padding: EdgeInsets.only(bottom: screenHeight * 0.01)),
									Row(children: [
										Padding(padding: EdgeInsets.only(right: screenWidth * 0.07)),
										Column(children: [
											SizedBox(
												width: screenWidth * 0.8,
												child: Text(
													"Total Owed",
													style:GoogleFonts.bebasNeue( 
														fontSize: 30,	
														color: lightTextColor,
													),	
												),
											),
											SizedBox(
												width: screenWidth * 0.8,
												child: RichText(
													text: TextSpan(
														text: "\$$totalOwedInt",
														style: GoogleFonts.bebasNeue(
															fontSize: 55,
															fontWeight: FontWeight.bold,
															color: darkTextColor,
														),
														children: <TextSpan>[
															TextSpan(
																text: ",$totalOwedDec",
																style: TextStyle(
																	fontSize: 45,
																	fontWeight: FontWeight.bold,
																	color: lightTextColor,	
																),
															),	
														],
													),
												),	
											),
										]),
										const Spacer(),
									]),

									Container(
										width: screenWidth * 0.86,
										height: 25,	
										decoration: BoxDecoration(
											borderRadius: BorderRadius.all(Radius.circular(35)),
											color: yellowDetailColor,
										),
									),
									const  Spacer(),
								],
							),
						),

						// Bottom Elements
						Padding(padding: EdgeInsets.only(bottom: 10)),
						Text(
							"T I M E   T O   P A Y   Y O U R   D U E S !",
							style: GoogleFonts.bebasNeue(
								fontSize: 20,
								color: whiteTextColor,
							),
						),
						Padding(padding: EdgeInsets.only(bottom: 20)),
						moneyData["data"].isNotEmpty
							? SizedBox(
								height: 200,	
								child: ListView.builder(
									shrinkWrap: true,
									scrollDirection: Axis.horizontal,
									itemCount: moneyData["data"].length + 1,
									itemBuilder: (BuildContext context, int index) {
										return Padding(
											padding: EdgeInsets.only(
												left: index == 0 ? 25 : 10,
												top: 3,
												right: index == moneyData["data"].length ? 25 : 10,
												bottom: 3,
											),
											child: index == 0
												? AddButton()
												: MoneyBox(
														index: index - 1,
														bgColor: moneyBoxColors[moneyData["data"][index - 1]["colorIndex"]],
														name: moneyData["data"][index - 1]["name"],
														money: moneyData["data"][index - 1]["money"],
														percentage: (
															moneyData["data"][index - 1]["money"] / totalOwed * 100
														).toInt(),
													),
										);
									}
								),
							)
							: Row(children: [
								Padding(padding: EdgeInsets.only(right: 25)),
								AddButton(),
								const Spacer(),
							]),

						// Transactions
						Padding(padding: EdgeInsets.only(bottom: 30)),
						Row(children: [
							Padding(padding: EdgeInsets.only(right: screenWidth * 0.1)),
							RichText(
								text: TextSpan(
									text: "Transactions ",
									style: GoogleFonts.bebasNeue(
										fontSize: 30,	
										color: whiteTextColor,
									),
									children: <TextSpan>[
										TextSpan(
											text: " (last 10)",
											style: TextStyle(
												fontSize: 20,
												fontWeight: FontWeight.bold,
												color: whiteTextColor,	
											),
										),	
									],
								),
							),
							const Spacer(),
						]),

						transactionData["data"].isNotEmpty
							? SizedBox(
								height: 10 * 100,	
								child: ListView.builder(
									shrinkWrap: true,
									scrollDirection: Axis.vertical,
									physics: const NeverScrollableScrollPhysics(),
									itemCount: transactionData["data"].length > 10
										? 10
										: transactionData["data"].length,
									itemBuilder: (BuildContext context, int index) {
										return Padding(
											padding: EdgeInsets.only(
												left: 25,
												top: 7,
												right: 25,
												bottom: 7,
											),
											child: transactionData["data"][index].isNotEmpty
												? TransactionBox(
													name: transactionData["data"][transactionData["data"].length - 1 - index]["name"],
													adding: transactionData["data"][transactionData["data"].length - 1 - index]["adding"],
													money: transactionData["data"][transactionData["data"].length - 1 - index]["money"].toStringAsFixed(2),
												
												)
												: SizedBox(height: 0,),
										);
									}
								),
							)
									: SizedBox(
										height: 500,
									),	
					]),
      	),
			),
    );
  }

	loadData() async {
		final SharedPreferences prefs = await SharedPreferences.getInstance();

		//prefs.remove("moneydata");

		// Get Username
		String u = prefs.getString("username") ?? "John Doe";
		setState(() {
			username = u;
		});

		// Get Money Data
		String moneyDataString = prefs.getString("moneydata") ?? '{"data":[]}';
		Map<String, dynamic> moneyDataMap = jsonDecode(moneyDataString);	
		setState(() {
			moneyData = moneyDataMap;
		});

		// Get Total Money Owed
		if (moneyData["data"].isNotEmpty) {
			double tot = 0;
			for(int i = 0; i < moneyData["data"].length; i++) {
				tot += moneyData["data"][i]["money"];
			}
			setState(() {
				totalOwed = tot;
			});

			String formattedTotalOwed = numberFormat.format(
				double.parse(
					totalOwed.toStringAsFixed(2),
				),
			);
			final moneySplit = formattedTotalOwed.split(',');
			if (moneySplit.length == 2) {
				setState(() {
					totalOwedInt = moneySplit[0];
					totalOwedDec = moneySplit[1];
				});
			} else {
				setState(() {
					totalOwedInt = moneySplit[0];
					totalOwedDec = "00";
				});
			}
		} else {
			setState(() {
				totalOwedInt = "0";
				totalOwedDec = "00";
			});
		}

		// Get Transaction Data
		String transactionDataString = prefs.getString("transactiondata") ?? '{"data":[]}';
		Map<String, dynamic> transactionDataMap = jsonDecode(transactionDataString);	
		setState(() {
			transactionData = transactionDataMap;
		});
	}

	editUsername() async {
		final SharedPreferences prefs = await SharedPreferences.getInstance();
		await prefs.setString("username", usernameTextEditingController.text);

		setState(() {
			username = usernameTextEditingController.text;
			editingUsername = false;
		});
	}
}

