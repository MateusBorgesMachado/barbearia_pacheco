import 'package:barbearia_pacheco/core/utils/error_messages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('traduz conflito de horário', () {
    expect(
      userFacingError(Exception('Horário indisponível')),
      'Este horário já está ocupado. Escolha outro.',
    );
    expect(
      userFacingError(Exception('horario indisponivel para o barbeiro')),
      'Este horário já está ocupado. Escolha outro.',
    );
    expect(
      userFacingError('PostgrestException: duplicate key value'),
      'Este horário já está ocupado. Escolha outro.',
    );
    expect(
      userFacingError(Exception('unique constraint appointments')),
      'Este horário já está ocupado. Escolha outro.',
    );
  });

  test('traduz antecedência, permissão e dados obrigatórios', () {
    expect(
      userFacingError(Exception('Cancelamento exige 5 horas')),
      'Cancelamento só é permitido com 5 horas de antecedência.',
    );
    expect(
      userFacingError(Exception('Não autorizado')),
      'Você não tem permissão para essa ação.',
    );
    expect(
      userFacingError('nao autorizado'),
      'Você não tem permissão para essa ação.',
    );
    expect(
      userFacingError(Exception('permission denied')),
      'Você não tem permissão para essa ação.',
    );
    expect(
      userFacingError('42501'),
      'Você não tem permissão para essa ação.',
    );
    expect(
      userFacingError(Exception('Selecione ao menos um serviço')),
      'Selecione ao menos um serviço para agendar.',
    );
    expect(
      userFacingError('selecione ao menos um servico'),
      'Selecione ao menos um serviço para agendar.',
    );
    expect(
      userFacingError(Exception('Informe o nome do cliente')),
      'Informe o nome do cliente.',
    );
  });

  test('remove prefixos técnicos e devolve o restante', () {
    expect(userFacingError(Exception('falha de rede')), 'falha de rede');
    expect(userFacingError('mensagem crua'), 'mensagem crua');
  });
}
