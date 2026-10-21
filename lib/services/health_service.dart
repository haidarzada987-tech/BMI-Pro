import '../models/user_profile.dart';
class HealthService {
  const HealthService();
  double bmr({required Gender gender,required int age,required double weightKg,required double heightCm}) { final v=10*weightKg+6.25*heightCm-5*age; return gender==Gender.male?v+5:v-161; }
  double multiplier(ActivityLevel l)=>switch(l){ActivityLevel.sedentary=>1.2,ActivityLevel.lightlyActive=>1.375,ActivityLevel.moderatelyActive=>1.55,ActivityLevel.veryActive=>1.725,ActivityLevel.extremelyActive=>1.9};
  double tdee(double b,ActivityLevel l)=>b*multiplier(l);
}
