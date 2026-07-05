class TurnoHorarios {
  final String titulo;
  final int horaInicio;
  final int minutoInicio;
  final int horaFim;
  final int minutoFim;

  TurnoHorarios({
    required this.titulo,
    required this.horaInicio,
    this.minutoInicio = 0,
    required this.horaFim,
    this.minutoFim = 0,
  });

  List<String> gerarIntervalos() {
    List<String> slots = [];
    int horaAtual = horaInicio;
    int minutoAtual = minutoInicio;

    while (horaAtual < horaFim ||
        (horaAtual == horaFim && minutoAtual <= minutoFim)) {
      String hh = horaAtual.toString().padLeft(2, '0');
      String mm = minutoAtual.toString().padLeft(2, '0');
      slots.add("$hh:$mm");

      minutoAtual += 15;
      if (minutoAtual >= 60) {
        horaAtual += 1;
        minutoAtual -= 60;
      }
    }
    return slots;
  }
}
