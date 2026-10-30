import '../models/subscription_plan.dart';

/// P-44 (#129): lectura del catálogo de planes publicados por el servidor.
///
/// La lista se filtra por `is_active` en la consulta; nunca se decide en el
/// cliente qué planes existen.
abstract class SubscriptionPlanRepository {
  Future<PlanCatalog> loadCatalog();
}
