#include "godot_pid_controller.h"

using namespace godot;

void PDController::_register_methods() {
  register_method("get_output", &PDController::get_output);
  register_property<PDController, double>("k_p", &PDController::k_p, 1.0);
  register_property<PDController, double>("k_d", &PDController::k_d, 1.0);
}

PDController::PDController() { }
PDController::~PDController() {}

void PDController::_init() {
  k_p = 1.0;
  k_d = 1.0;
  d = 0.0;
  last_error = 0.0;
}

double PDController::get_output(double error, float dt) {
  d = (error - last_error) / dt;
  last_error = error;
  return (error * k_p) + (d * k_d);
}


void PIDController::_register_methods() {
  register_method("get_output", &PIDController::get_output);
  register_property<PIDController, double>("k_p", &PIDController::k_p, 1.0);
  register_property<PIDController, double>("k_i", &PIDController::k_i, 1.0);
  register_property<PIDController, double>("k_d", &PIDController::k_d, 1.0);
}

PIDController::PIDController() {}
PIDController::~PIDController() {}

void PIDController::_init() {
  k_p = 1.0;
  k_i = 1.0;
  k_d = 1.0;
  i = 0.0;
  d = 0.0;
  last_error = 0.0;
}

double PIDController::get_output(double error, float dt) {
  i += error * dt;
  d = (error - last_error) / dt;
  last_error = error;
  return (error * k_p) + (i * k_i) + (d * k_d);
}
