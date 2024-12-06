class Installation {
  final int id;
  final String numeroSolicitud;
  final String? numeroSuministro;  // Nullable
  final String? numeroContratoSuministro;  // Nullable
  final DateTime? fechaAprobacionContrato;  // Nullable
  final String estadoNombre;
  final String estadoBadge;
  final String solicitanteNombre;
  final String? direccion;  // Nullable
  final String distrito;
  final String? ubicacion;

  Installation({
    required this.id,
    required this.numeroSolicitud,
    this.numeroSuministro,
    this.numeroContratoSuministro,
    this.fechaAprobacionContrato,
    required this.estadoNombre,
    required this.estadoBadge,
    required this.solicitanteNombre,
    this.direccion,
    required this.distrito,
    this.ubicacion,
  });

  factory Installation.fromJson(Map<String, dynamic> json) {
    return Installation(
      id: json['id'],
      numeroSolicitud: json['numero_solicitud'],
      numeroSuministro: json['numero_suministro'],
      numeroContratoSuministro: json['numero_contrato_suministro'],
      fechaAprobacionContrato: json['fecha_aprobacion_contrato'] != null ? DateTime.parse(json['fecha_aprobacion_contrato']) : null,
      estadoNombre: json['estado_nombre'],
      estadoBadge: json['estado_badge'],
      solicitanteNombre: json['solicitante_nombre'],
      direccion: json['direccion'],
      distrito: json['distrito'],
      ubicacion: json['ubicacion'],
    );
  }
}