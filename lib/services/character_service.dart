import '../models/character_config.dart';
import '../models/user_profile.dart';
class CharacterService {
  const CharacterService();
  CharacterConfig select({required Gender gender,required int age,required double bmi}) {
    final ageGroup=age<30?'young':age<55?'adult':'senior';
    final weightGroup=bmi<18.5?'slim':bmi<25?'normal':bmi<30?'plus':'heavy';
    final sex=gender==Gender.female?'female':'male';
    return CharacterConfig(gender:gender,ageGroup:ageGroup,weightGroup:weightGroup,assetPath:'assets/characters/$sex/$ageGroup/$weightGroup.png');
  }
}
