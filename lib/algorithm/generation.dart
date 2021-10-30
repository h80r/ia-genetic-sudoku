import 'dart:math';

import 'package:genetic_sudoku/algorithm/chromosome.dart';
import 'package:genetic_sudoku/models/cell.dart';
import 'package:genetic_sudoku/models/grid.dart';

/// Representa uma geração do algoritmo.
///
/// * [population] armazena todos os cromossomos da geração.
/// * [generationNumber] indica qual o número da geração produzida.
class Generation {
  /// Produz uma [Generation] aleatória.
  ///
  /// A geração criada possuirá uma população de tamanho [size] e será
  /// preenchida com cromossomos gerados aleatoriamente.
  Generation({
    required this.generationNumber,
    required int size,
    required List<Cell> fixedCells,
  }) {
    population = List.generate(size, (index) => Chromosome(fixedCells));
  }

  /// Reproduz a geração anterior para criar uma nova [Generation].
  ///
  /// Utiliza uma geração anterior, [previous], como pai da nova geração.
  /// A chance de mutação é definida em [mutationRate].
  Generation.reproduce({
    required this.generationNumber,
    required Generation previous,
    required double mutationRate,
  }) {
    final elitism = previous.fittest;

    population = [elitism];

    while (population.length < previous.population.length) {
      final crossingPoint = Random().nextInt(81);
      final parent1 = previous.getParent();
      final parent2 = previous.getParent(avoid: parent1);

      final child1 = Chromosome.fromParents(
        parent1,
        parent2,
        crossingPoint: crossingPoint,
        mutationRate: mutationRate,
      )..applyFitness();

      final child2 = Chromosome.fromParents(
        parent2,
        parent1,
        crossingPoint: crossingPoint,
        mutationRate: mutationRate,
      )..applyFitness();

      population.add(child1.fitness < child2.fitness ? child1 : child2);
    }
  }

  /// A população da geração observada.
  ///
  /// É composta por uma lista de [Chromosome].
  late final List<Chromosome> population;

  /// O número da geração observada.
  final int generationNumber;

  /// Calcula a pontuação da geração atual.
  ///
  /// Chama a função [applyFitness] para cada cromossomo da população.
  void applyFitness() {
    for (var chromosome in population) {
      chromosome.applyFitness();
    }
  }

  /// Realiza uma seleção por torneio para escolher um pai aleatório para
  /// reprodução.
  ///
  /// O [tournamentSize] determina o percentual da população que será escolhido
  /// aleatoriamente para participar do torneio.
  /// Deste grupo, apenas o melhor será escolhido como pai válido.
  ///
  /// O [avoid] é opcional e indica um cromossomo que não deve ser escolhido.
  Chromosome getParent({double tournamentSize = 0.1, Chromosome? avoid}) {
    final pool = List.of(population)
      ..remove(avoid)
      ..shuffle()
      ..take((tournamentSize * population.length).round());
    return pool.reduce((best, e) => e.fitness < best.fitness ? e : best);
  }

  /// Retorna o melhor cromossomo da geração.
  Chromosome get fittest =>
      population.reduce((a, b) => a.fitness < b.fitness ? a : b);

  /// Retorna o pior cromossomo da geração.
  Chromosome get unfittest =>
      population.reduce((a, b) => a.fitness > b.fitness ? a : b);
}

/// Uma representação simplificada de [Generation].
///
/// Armazena apenas os dados que são relevantes para apresentação do sudoku no
/// aplicativo:
///
/// * [fittest] e [unfittest] são o melhor e pior sudokus da geração.
/// * [fitness] é a pontuação da geração.
/// * [generationNumber] é o número da geração armazenada.
class GenerationLog {
  /// Gera um novo registro de geração.
  GenerationLog({
    required this.fittest,
    required this.unfittest,
    required this.fitness,
    required this.generationNumber,
  });

  /// Simplifica a [generation] enviada, criando um novo [GenerationLog].
  GenerationLog.fromGeneration({required Generation generation})
      : fittest = generation.fittest.grid,
        unfittest = generation.unfittest.grid,
        fitness = generation.fittest.fitness,
        generationNumber = generation.generationNumber;

  /// Sudoku do melhor cromossomo da geração.
  ///
  /// Em vez de armazenar [Chromosome], que possui muitos dados além do que é
  /// requisitado para exibição no aplicativo, utiliza [Grid] para armazenar
  /// apenas o que faz parte da representação visual do sudoku.
  final Grid fittest;

  /// Sudoku do pior cromossomo da geração.
  final Grid unfittest;

  /// Pontuação do melhor cromossomo da geração.
  final int fitness;

  /// Número da geração que está sendo registrada.
  final int generationNumber;
}
