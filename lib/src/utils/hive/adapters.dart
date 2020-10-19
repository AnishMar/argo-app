library adapters;

import 'package:Argo/src/utils/magister/magister.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
part 'adapters.g.dart';

extension StringExtension on String {
  String get cap => "${this[0].toUpperCase()}${this.substring(1)}";
}

DateFormat formatDatum = DateFormat("EEEE dd MMMM");

@HiveType(typeId: 1)
class Account extends HiveObject {
  @HiveField(0)
  String address;
  @HiveField(1)
  String birthdate;
  @HiveField(2)
  String email;
  @HiveField(3)
  String fullName;
  @HiveField(4)
  String initials;
  @HiveField(5)
  String klas;
  @HiveField(6)
  String klasCode;
  @HiveField(7)
  String mentor;
  @HiveField(8)
  String name;
  @HiveField(9)
  String officialFullName;
  @HiveField(10)
  String phone;
  @HiveField(11)
  String profiel;
  @HiveField(12)
  String username;
  @HiveField(13)
  String tenant;

  @HiveField(14)
  String accessToken;
  @HiveField(15)
  String refreshToken;

  @HiveField(16)
  int expiry;
  @HiveField(17)
  int id;

  @HiveField(18)
  String profilePicture;

  @HiveField(19)
  List<Absentie> afwezigheid;
  @HiveField(20)
  List<Bericht> berichten;
  @HiveField(21)
  List<CijferJaar> cijfers;
  @HiveField(22)
  Map<String, List<List<Les>>> lessons;
  Magister magister;
  Account([Map tokenSet]) {
    this.magister = Magister(this);
    if (tokenSet != null) {
      this.accessToken = tokenSet["access_token"];
      this.refreshToken = tokenSet["refresh_token"];
    }

    this.address = "";
    this.birthdate = "";
    this.email = "";
    this.fullName = "";
    this.id = 0;
    this.initials = "";
    this.klas = "";
    this.klasCode = "";
    this.mentor = "";
    this.name = "";
    this.officialFullName = "";
    this.phone = "-";
    this.profiel = "";
    this.username = "";
    this.accessToken = tokenSet != null ? tokenSet["access_token"] : "";
    this.refreshToken = tokenSet != null ? tokenSet["refresh_token"] : "";
    this.tenant = "";
    this.expiry = 8640000000000000;
    this.afwezigheid = <Absentie>[];
    this.berichten = <Bericht>[];
    this.cijfers = <CijferJaar>[];
    this.lessons = {}.cast<String, List<List<Les>>>();
  }
  void saveTokens(tokenSet) {
    this.accessToken = tokenSet["access_token"];
    this.refreshToken = tokenSet["refresh_token"];
    if (this.isInBox) this.save();
  }

  String toString() => this.fullName;
}

@HiveType(typeId: 2)
class Les {
  @HiveField(0)
  int start;
  @HiveField(1)
  int duration;
  @HiveField(2)
  int id;
  @HiveField(3)
  String startTime;
  @HiveField(4)
  String endTime;
  @HiveField(5)
  String description;
  @HiveField(6)
  String title;
  @HiveField(7)
  String location;
  @HiveField(8)
  String date;
  @HiveField(9)
  String vak;
  @HiveField(10)
  String docent;
  @HiveField(11)
  String huiswerk;
  @HiveField(12)
  String information;
  @HiveField(13)
  String hour;
  @HiveField(14)
  bool huiswerkAf;
  @HiveField(15)
  bool uitval;
  @HiveField(16)
  bool editable;

  Les([Map les]) {
    if (les == null) return;
    DateTime start = DateTime.parse(les["Start"]).toLocal();
    DateTime end = DateTime.parse(les["Einde"]).toLocal();
    int startHour = les['LesuurVan'];
    int endHour = les["LesuurTotMet"];

    DateFormat formatHour = DateFormat("HH:mm");
    DateFormat formatDatum = DateFormat("EEEE dd MMMM");
    var docent;
    int minFromMidnight = start.difference(DateTime(end.year, end.month, end.day)).inMinutes;
    var hour = (startHour == endHour ? startHour.toString() : '$startHour - $endHour');
    if (les["Docenten"] != null && !les["Docenten"].isEmpty) {
      docent = les["Docenten"][0]["Naam"];
    }
    this.start = minFromMidnight ?? "";
    this.duration = end.difference(start).inMinutes ?? "";
    this.hour = hour == "null" ? "" : hour;
    this.startTime = formatHour.format(start);
    this.endTime = formatHour.format(end);
    this.description = les["Inhoud"] ?? "";
    this.title = les["Omschrijving"] ?? "";
    this.location = les["Lokatie"];
    this.date = formatDatum.format(end);
    this.vak = les["Vakken"].isEmpty ? les["Omschrijving"] : les["Vakken"][0]["Naam"];
    this.docent = docent;
    this.huiswerk = les["Inhoud"];
    this.huiswerkAf = les["Afgerond"];
    this.uitval = les["Status"] == 5;
    this.information = (!["", null].contains(les["Lokatie"]) ? les["Lokatie"] + " • " : "") + formatHour.format(start) + " - " + formatHour.format(end) + (les["Inhoud"] != null ? " • " + les["Inhoud"].replaceAll(RegExp("<[^>]*>"), "") : "");
    this.editable = les["Type"] == 1;
    this.id = les["Id"];
  }
}

@HiveType(typeId: 3)
class CijferJaar {
  @HiveField(0)
  int id;
  @HiveField(1)
  String eind;
  @HiveField(2)
  String leerjaar;
  @HiveField(3)
  List<Cijfer> cijfers;
  @HiveField(4)
  List<Periode> perioden;
  CijferJaar([jaar]) {
    if (jaar != null) {
      this.id = jaar["id"];
      this.eind = jaar["einde"];
      this.leerjaar = jaar["studie"]["code"];
    }
    this.cijfers = [];
    this.perioden = [];
  }
}

@HiveType(typeId: 4)
class Periode {
  @HiveField(0)
  String abbr;
  @HiveField(1)
  String naam;
  @HiveField(2)
  int id;
  Periode([Map per]) {
    if (per != null) {
      this.abbr = per["Naam"];
      this.naam = per["Omschrijving"];
      this.id = per["Id"];
    }
  }
}

@HiveType(typeId: 5)
class Cijfer {
  @HiveField(0)
  DateTime ingevoerd;
  @HiveField(1)
  String cijfer;
  @HiveField(2)
  Vak vak;
  @HiveField(3)
  Periode periode;
  @HiveField(4)
  int kolomId;
  @HiveField(5)
  String title;
  @HiveField(6)
  int id;
  @HiveField(7)
  bool voldoende;
  @HiveField(8)
  double weging;
  Cijfer([Map cijfer]) {
    if (cijfer != null) {
      this.ingevoerd = DateTime.parse(cijfer["DatumIngevoerd"] ?? "1970-01-01T00:00:00.0000000Z");
      this.cijfer = cijfer["CijferStr"];
      this.periode = Periode(cijfer["CijferPeriode"]);
      this.vak = Vak(cijfer["Vak"]);
      this.kolomId = cijfer["CijferKolom"]["Id"];
      this.id = cijfer["Id"];
      this.voldoende = cijfer["IsVoldoende"];
    }
  }
}

@HiveType(typeId: 6)
class Vak {
  String toString() => this.naam;
  @HiveField(0)
  String naam;
  @HiveField(1)
  int id;
  Vak([vak]) {
    if (vak != null) {
      this.naam = (vak["Omschrijving"] as String).cap;
      this.id = vak["Id"];
    }
  }
}

@HiveType(typeId: 7)
class Bericht {
  @HiveField(0)
  String dag;
  @HiveField(1)
  int id;
  @HiveField(2)
  bool prioriteit;
  @HiveField(3)
  bool bijlagen;
  @HiveField(4)
  String onderwerp;
  @HiveField(5)
  String afzender;

  String inhoud;
  String ontvangers;
  String cc;
  Bericht([Map ber]) {
    if (ber != null) {
      this.dag = formatDatum.format(DateTime.parse(ber["verzondenOp"]));
      this.id = ber["id"];
      this.prioriteit = ber["heeftPrioriteit"];
      this.bijlagen = ber["heeftBijlagen"];
      this.onderwerp = ber["onderwerp"];
      this.afzender = ber["afzender"]["naam"];

      if (ber["inhoud"] != null) {
        this.inhoud = ber["inhoud"];
        this.ontvangers = ber["ontvangers"].take(10).map((ont) => ont["weergavenaam"]).join(", ");
        this.cc = ber["kopieOntvangers"].isEmpty ? null : ber["kopieOntvangers"].take(10).map((ont) => ont["weergavenaam"]).join(", ");
      }
    }
  }
}

@HiveType(typeId: 8)
class Absentie {
  @HiveField(0)
  String dag;
  @HiveField(1)
  String type;
  @HiveField(2)
  Les les;
  @HiveField(3)
  bool geoorloofd;
  Absentie([Map afw]) {
    if (afw != null) {
      this.dag = formatDatum.format(DateTime.parse(afw["Afspraak"]["Einde"]));
      this.type = afw["Omschrijving"];
      this.les = Les(afw["Afspraak"]);
      this.geoorloofd = afw["Geoorloofd"];
    }
  }
}

class MaterialColorAdapter extends TypeAdapter<MaterialColor> {
  @override
  final typeId = 100;

  @override
  MaterialColor read(BinaryReader reader) => MaterialColor(reader.readInt(), {});

  @override
  void write(BinaryWriter writer, MaterialColor obj) => writer.writeInt(obj.value);
}

class ColorAdapter extends TypeAdapter<Color> {
  @override
  final typeId = 101;

  @override
  Color read(BinaryReader reader) => Color(reader.readInt());

  @override
  void write(BinaryWriter writer, Color obj) => writer.writeInt(obj.value);
}
