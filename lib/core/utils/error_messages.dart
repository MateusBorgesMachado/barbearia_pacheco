String userFacingError(Object error) {
  final text = error
      .toString()
      .replaceAll('Exception: ', '')
      .replaceAll('PostgrestException: ', '')
      .replaceAll('AuthException: ', '');

  final lower = text.toLowerCase();

  if (lower.contains('horário indisponível') ||
      lower.contains('horario indisponivel') ||
      lower.contains('unique') ||
      lower.contains('duplicate')) {
    return 'Este horário já está ocupado. Escolha outro.';
  }

  if (lower.contains('5 horas')) {
    return 'Cancelamento só é permitido com 5 horas de antecedência.';
  }

  if (lower.contains('não autorizado') ||
      lower.contains('nao autorizado') ||
      lower.contains('permission denied') ||
      lower.contains('42501')) {
    return 'Você não tem permissão para essa ação.';
  }

  if (lower.contains('selecione ao menos um serviço') ||
      lower.contains('selecione ao menos um servico')) {
    return 'Selecione ao menos um serviço para agendar.';
  }

  if (lower.contains('informe o nome do cliente')) {
    return 'Informe o nome do cliente.';
  }

  return text;
}
