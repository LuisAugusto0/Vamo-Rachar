import 'package:flutter/material.dart';
class TeamMember {
  final String name;
  final String role;
  final String avatarUrl;

  TeamMember({required this.name, required this.role, required this.avatarUrl});
}

final List<TeamMember> teamMembers = [
  TeamMember(
    name: "Gabriel de Cortez Mourão",
    role: "Desenvolvedor Backend",
    avatarUrl: "https://avatars.githubusercontent.com/u/65474060?v=4",
  ),
  TeamMember(
    name: "Luís Augusto Lima de Oliveira",
    role: "Desenvolvedor Backend",
    avatarUrl: "https://avatars.githubusercontent.com/u/66066037?v=4",
  ),
  TeamMember(
    name: "Mateus Fernandes Barbosa",
    role: "Desenvolvedor Frontend",
    avatarUrl: "https://avatars.githubusercontent.com/u/129770657?v=4",
  ),
  TeamMember(
    name: "Victor Ferraz de Moraes",
    role: "Desenvolvedor Frontend",
    avatarUrl: "https://avatars.githubusercontent.com/u/102532350?v=4",
  ),
];

class SobreNos extends StatelessWidget {
  const SobreNos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.close,
                  size: 35,
                  color: Color(0xEEEEEEEE),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título "Membros do Time"
              const Text(
                "Membros do Time",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Título em branco
                ),
              ),
              const SizedBox(height: 16),

              // Caixa com bordas arredondadas para a lista de membros
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, // Fundo branco
                  borderRadius: BorderRadius.circular(15), // Bordas arredondadas
                ),
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  shrinkWrap: true, // Permite que a lista se ajuste ao conteúdo
                  physics: const NeverScrollableScrollPhysics(), // Desativa o scroll interno da lista
                  itemCount: teamMembers.length,
                  itemBuilder: (context, index) {
                    final member = teamMembers[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          userAvatar(member.avatarUrl, radius: 30.0), // Avatar
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                member.role,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Título "Sobre a equipe"
              const Text(
                "Sobre a equipe",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Título em branco
                ),
              ),
              const SizedBox(height: 10),

              // Texto corrido sobre a equipe
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  "Somos um grupo de alunos cursando Ciência da Computação (atualmente no 4º Período) na PUC Minas. Desenvolvemos este projeto durante a disciplina de Laboratório de Desenvolvimento de Dispositivos Móveis com o objetivo de facilitar a situação corriqueira de dividir os gastos entre diferentes pessoas pagantes em estabelecimentos de consumo de produtos diversos. Ainda estamos ganhando experiência em desenvolvimento mobile, portanto qualquer feedback ou crítica será de grande valor para nós!",
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget userAvatar(String avatarUrl, {double radius = 30.0}) {
    return CircleAvatar(
      backgroundImage: NetworkImage(avatarUrl),
      radius: radius,
    );
  }
}
