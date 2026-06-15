class TurnoHorarios {
  final String titulo;
  final int horaInicio;
  final int horaFim;

  TurnoHorarios({
    required this.titulo,
    required this.horaInicio,
    required this.horaFim,
  });

  List<String> gerarIntervalos() {
    List<String> lista = [];
    for (int hora = horaInicio; hora < horaFim; hora++) {
      for (int minuto = 0; minuto < 60; minuto += 15) {
        final String h = hora.toString().padLeft(2, '0');
        final String m = minuto.toString().padLeft(2, '0');
        lista.add("$h:$m");
      }
    }
    return lista;
  }
}
