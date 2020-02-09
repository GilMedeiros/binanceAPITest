import 'dart:convert';
import 'package:binance_plus_app/data_search.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteBloc implements BlocBase {


    Map<String, Coin> _favorites = {};

    final _favController = BehaviorSubject<Map<String, Coin>>(seedValue: {});
    Stream<Map<String, Coin>> get outFav => _favController.stream;

    FavoriteBloc(){
      SharedPreferences.getInstance().then((prefs){
        if(prefs.getKeys().contains("favorites")){
          _favorites = json.decode(prefs.getString("favorites")).map((n,m){
            return MapEntry(n,Coin.fromJson(m));
          }).cast<String, Coin>();
          _favController.add(_favorites);
        }
      });
    }
  void toggleFavorite(Coin coin){
  if(_favorites.containsKey(coin.symbol)) _favorites.remove(coin.symbol);
  else _favorites[coin.symbol] = coin;
  _favController.sink.add(_favorites);
  _saveFac();
  }
  void _saveFac(){
      SharedPreferences.getInstance().then((prefs){
        prefs.setString("favorites",json.encode(_favorites));
        print(prefs.getString("favorites"));
      });
  }

  @override
  void dispose() {
    _favController.close();
  }
}