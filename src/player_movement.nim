
import godot
import godotapi / [kinematic_body, input, input_event_mouse_button, input_event_mouse_motion, scene_tree, spatial]
import strutils

gdobj PlayerMovement of KinematicBody:

    var default_height: float = 1.0 # soon...
    var crouch_height: float = 0.5  # soon...

    var speed: float = 1.0               # speed of character
    var default_move_speed: float = 1.0  # soon...
    var crouch_move_speed: float = 0.5   # soon...
    var run_move_speed: float = 2.0      # soon...

    var gravity: float = 20.0     # gravity
    var gravity_vec: Vector3      # gravity
    var jump_power: float = 5     # jump
    var mouse_sensitivity: float = 0.5    # mouse movement 

    var direction: Vector3 # movement

    var velocity: Vector3 # movement

    var head: Spatial # controls with mouse movement 


    method ready*() =
        self.head = self.getNode("head") as Spatial
        self.setProcessInput(true)
        self.setPhysicsProcess(true)

    method input*(event : InputEvent) =
        if event of InputEventMouseMotion:
            let ev = event as InputEventMouseMotion
            var rotation = self.rotation         # Error: 'rotation(self).y' cannot be assigned to
            var head_rotation = self.head.rotation
            head_rotation.x -= ev.relative.y / 8 * self.mouse_sensitivity 
            rotation.y -= ev.relative.x / 8 * self.mouse_sensitivity

            self.rotation = rotation
            self.head.rotation  = head_rotation
            self.head.rotationDegrees = clamp(self.head.rotationDegrees , vec3(-85, 0,0) , vec3(85, 0,0))

            #[Error: 'rotation(self).y' cannot be assigned to

            let ev = event as InputEventMouseMotion
            self.rotation.y = -ev.relative.x / 8 * self.mouse_sensitivity
            self.head.rotation.x = -ev.relative.y / 8 * self.mouse_sensitivity
            self.head.rotationDegrees = clamp(self.head.rotationDegrees , vec3(-85, 0,0) , vec3(85, 0,0))
            ]#



    method physicsProcess*(delta: float64) =
        
        self.direction.zero()
        var rotation = self.rotation

        # gravity
        if self.isOnFloor():
            self.gravity_vec = -self.getFloorNormal()
        else:
            self.gravity_vec += vec3(0,-1.0 ,0) * self.gravity * delta

        if isActionPressed("front_move"):
            self.direction.z -= 2
        elif isActionPressed("back_move"):
            self.direction.z += 2
        if isActionPressed("left_move"):
            self.direction.x -= 2
        elif isActionPressed("right_move"):
            self.direction.x += 2

        if isActionJustPressed("jump"):
            if self.isOnFloor():
                self.gravity_vec.y = self.jump_power
        
        if isActionJustPressed("exit"):
            self.getTree().quit()
        


        discard self.direction.normalized()
        self.direction = self.direction.rotated(vec3(0,1,0), rotation.y)
        
        self.velocity.z = self.direction.z * self.speed
        self.velocity.x = self.direction.x * self.speed
        self.velocity.y = self.gravity_vec.y
        discard self.moveAndSlide(self.velocity, vec3(0,1,0), true)