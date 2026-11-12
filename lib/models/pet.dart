const List<String> petSpecies = ['Cão', 'Gato', 'Pássaro', 'Coelho', 'Outro'];
const List<String> petGenders = ['Macho', 'Fêmea', 'Desconhecido'];

class Pet {
  final int? id;
  final String name;
  final String species;
  final String breed;
  final int age;
  final double weight;
  final String gender;
  final String medicalNotes;

  const Pet({
    this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.weight,
    required this.gender,
    this.medicalNotes = '',
  });

  factory Pet.fromMap(Map<String, Object?> map) {
    return Pet(
      id: map['id'] as int?,
      name: map['name'] as String,
      species: map['species'] as String,
      breed: map['breed'] as String,
      age: map['age'] as int,
      weight: (map['weight'] as num).toDouble(),
      gender: map['gender'] as String,
      medicalNotes: (map['medical_notes'] as String?) ?? '',
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'weight': weight,
      'gender': gender,
      'medical_notes': medicalNotes,
    };
  }
}
