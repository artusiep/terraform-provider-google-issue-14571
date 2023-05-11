variable "name" {
  type        = string
  description = "name of the task"
}

variable "location" {
  type        = string
  description = "location of  the task"
}

variable "project_id" {
  description = "name of the project"
}

variable "retry_config" {
  default     = {}
  description = "If a job does not complete successfully, Ifan acknowledgement is not received from the handler, then it will be retried with mentioned configuration"
}

variable "rate_limits" {
  default     = {}
  description = "Rate limits for task dispatches."
}

variable "app_engine_routing_override" {
  type       = object({
    service = optional(string)
    version = optional(string)
    instance = optional(string)
  })
  default = {}
  description = "App Engine Routing for the task. If set, app_engine_routing_override is used for all tasks in the queue, no matter what the setting is for the task."
}

resource "google_cloud_tasks_queue" "this" {
  project  = var.project_id
  name     = var.name
  location = var.location
  dynamic "retry_config" {
    for_each = var.retry_config != {} ? [var.retry_config] : toset([])
    content {
      max_attempts       = try(retry_config.value.max_attempts, null)
      max_retry_duration = try(retry_config.value.max_retry_duration, null)
      max_backoff        = try(retry_config.value.max_backoff, null)
      min_backoff        = try(retry_config.value.min_backoff, null)
      max_doublings      = try(retry_config.value.max_doublings, null)
    }
  }
  dynamic "rate_limits" {
    for_each = var.rate_limits != {} ? [var.rate_limits] : toset([])
    content {
      max_concurrent_dispatches = try(rate_limits.value.max_concurrent_dispatches, null)
      max_dispatches_per_second = try(rate_limits.value.max_dispatches_per_second, null)
      max_burst_size            = try(rate_limits.value.max_burst_size, null)
    }
  }
  dynamic "app_engine_routing_override" {
    for_each = var.app_engine_routing_override != {} ? [var.app_engine_routing_override] : []
    content {
      service = try(var.app_engine_routing_override.service, null)
      version = try(var.app_engine_routing_override.version, null)
      host    = try(var.app_engine_routing_override.host, null)
    }
  }
}
