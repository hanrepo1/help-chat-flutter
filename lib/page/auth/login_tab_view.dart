import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:help_chat/page/auth/login_page.dart';
import 'package:help_chat/page/auth/register_page.dart';

class LoginTabView extends StatefulWidget {
  const LoginTabView({super.key});

  @override
  State<LoginTabView> createState() => _LoginTabViewState();
}

class _LoginTabViewState extends State<LoginTabView> with TickerProviderStateMixin {
	late TabController tabController;

	@override
  void initState() {
    tabController = TabController(
			initialIndex: 0,
			length: 2, 
			vsync: this
		);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LOGIN PAGE"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
			backgroundColor: Theme.of(context).colorScheme.surface,
			body: SingleChildScrollView(
				child: SizedBox(
					height: MediaQuery.of(context).size.height,
					child: Stack(
						children: [
							Align(
								alignment: const AlignmentDirectional(20, -1.2),
								child: Container(
									height: MediaQuery.of(context).size.width,
									width: MediaQuery.of(context).size.width,
									decoration: BoxDecoration(
										shape: BoxShape.circle,
										color: Theme.of(context).colorScheme.tertiary
									),
								),
							),
							Align(
								alignment: const AlignmentDirectional(2.7, -1.2),
								child: Container(
									height: MediaQuery.of(context).size.width / 1.3,
									width: MediaQuery.of(context).size.width / 1.3,
									decoration: BoxDecoration(
										shape: BoxShape.circle,
										color: Theme.of(context).colorScheme.primary
									),
								),
							),
							BackdropFilter(
								filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
								child: Container(),
							),
							Align(
								alignment: Alignment.center,
								child: SizedBox(
									height: MediaQuery.of(context).size.height / 1.8,
									child: Column(
										children: [
											Padding(
												padding: const EdgeInsets.symmetric(horizontal: 50.0),
												child: TabBar(
													controller: tabController,
													unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
													labelColor: Theme.of(context).colorScheme.onSurface,
													tabs: const [
														Padding(
															padding: EdgeInsets.all(12.0),
															child: Text(
																'Sign In',
																style: TextStyle(
																	fontSize: 18,
																),
															),
														),
														Padding(
															padding: EdgeInsets.all(12.0),
															child: Text(
																'Sign Up',
																style: TextStyle(
																	fontSize: 18,
																),
															),
														),
													],
												),
											),
											Expanded(
												child: TabBarView(
													controller: tabController,
													children: const [
														// BlocProvider<SignInBloc>(
														// 	create: (context) => SignInBloc(
														// 		context.read<AuthenticationBloc>().userRepository
														// 	),
														// 	child: const SignInScreen(),
														// ),
														// BlocProvider<SignUpBloc>(
														// 	create: (context) => SignUpBloc(
														// 		context.read<AuthenticationBloc>().userRepository
														// 	),
														// 	child: const SignUpScreen(),
														// ),
                            LoginPage(),
                            RegisterPage()
													],
												)
											)
										],
									),
								),
							)
						],
					),
				),
			),
		);
  }
}