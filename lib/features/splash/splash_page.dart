import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/storage/storage_service.dart';
class SplashPage extends StatefulWidget{const SplashPage({super.key});@override State<SplashPage> createState()=>_SplashPageState();}
class _SplashPageState extends State<SplashPage>{@override void initState(){super.initState();Timer(const Duration(milliseconds:500),(){if(mounted)context.go(StorageService.getProfile()==null?'/onboarding':'/dashboard');});}@override Widget build(BuildContext c)=>const Scaffold(body:Center(child:Text('BMI Pro',style:TextStyle(fontSize:36,fontWeight:FontWeight.w800))));}
