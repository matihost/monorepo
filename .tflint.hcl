# TFLint configuration used by pre-commit tflint hook.
config {
  # Terragrunt passes inputs (tags, aws_tags, ...) to the modules, which are not always used by every module,
  # so variables are allowed to be declared and not used.
  call_module_type = "none"
}

rule "terraform_unused_declarations" {
  enabled = false
}
