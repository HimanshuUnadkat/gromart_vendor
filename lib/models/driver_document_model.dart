
class DriverDocumentModel {
  List<Documents>? documents;
  String? id;
  String? type;

  DriverDocumentModel({this.documents, this.id});

  DriverDocumentModel.fromJson(Map<String, dynamic> json) {
    if (json['documents'] != null) {
      documents = <Documents>[];
      json['documents'].forEach((v) {
        documents!.add(Documents.fromJson(v));
      });
    }
    id = json['id'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (documents != null) {
      data['documents'] = documents!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    data['type'] = type;
    return data;
  }
}

class Documents {
  String? frontImage;
  String? status;
  String? documentId;
  String? backImage;

  Documents({this.frontImage, this.status, this.documentId, this.backImage});

  Documents.fromJson(Map<String, dynamic> json) {
    frontImage = json['frontImage'];
    status = json['status'];
    documentId = json['documentId'];
    backImage = json['backImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['frontImage'] = frontImage;
    data['status'] = status;
    data['documentId'] = documentId;
    data['backImage'] = backImage;
    return data;
  }
}
