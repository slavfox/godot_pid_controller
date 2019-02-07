#ifndef GDPIDCONTROLLER_H
#define GDPIDCONTROLLER_H

#include <Godot.hpp>
#include <Reference.hpp>

namespace godot {

  class PDController : public Reference {
    GODOT_CLASS(PDController, Reference)

    protected:
      double k_p;
      double k_d;
      double d;
      double last_error;

    public:
      static void _register_methods();
      void _init();

      PDController();
      ~PDController();

      double get_output(double error, float dt);
  };

  class PIDController : public Reference {
    GODOT_CLASS(PIDController, Reference)

    protected:
      double k_p;
      double k_i;
      double k_d;
      double i;
      double d;
      double last_error;
    public:
      static void _register_methods();
      void _init();

      PIDController();
      ~PIDController();

      double get_output(double error, float dt);
  };
}

#endif
