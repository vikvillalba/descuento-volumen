variable "prefijo" {
  description = "Inicio del nombre de los recursos"
  type        = string
  default     = "descuento"
}

variable "jar" {
  description = "Ruta al .jar de descuento-volumen"
  type        = string
  default     = "../target/descuento-volumen-1.0.0-SNAPSHOT.jar"
}

variable "memoria" {
  description = "Memoria de la función en MB"
  type        = number
  default     = 512

  validation {
    condition     = var.memoria >= 128 && var.memoria <= 1024
    error_message = "Para la clase: entre 128 y 1024 MB."
  }
}

variable "timeout" {
  description = "Segundos máximos por invocación"
  type        = number
  default     = 10
}
