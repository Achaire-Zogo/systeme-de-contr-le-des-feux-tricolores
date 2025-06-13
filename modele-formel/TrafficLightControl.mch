/*
 * Modèle Event-B pour le contrôle des feux tricolores
 * Ce modèle définit les états et événements d'un carrefour à quatre voies,
 * ainsi que les propriétés de sécurité à garantir.
 */

MACHINE TrafficLightControl

SETS
    DIRECTIONS = {NORTH, SOUTH, EAST, WEST};
    COLORS = {RED, YELLOW, GREEN};
    PEDESTRIAN_SIGNALS = {WALK, DONT_WALK};
    PHASES = {PHASE_NS, PHASE_EW, TRANSITION_NS_TO_EW, TRANSITION_EW_TO_NS}

VARIABLES
    traffic_lights,      // État des feux pour les véhicules
    pedestrian_signals,  // État des feux pour les piétons
    current_phase,       // Phase actuelle du cycle
    timer,               // Temps écoulé dans la phase actuelle
    queue_length,        // Longueur des files d'attente pour chaque direction
    waiting_time,        // Temps d'attente cumulé par direction
    total_waiting_time   // Temps d'attente total (objectif à minimiser)

INVARIANTS
    // Typage des variables
    traffic_lights ∈ DIRECTIONS → COLORS &
    pedestrian_signals ∈ DIRECTIONS → PEDESTRIAN_SIGNALS &
    current_phase ∈ PHASES &
    timer ∈ ℕ &
    queue_length ∈ DIRECTIONS → ℕ &
    waiting_time ∈ DIRECTIONS → ℕ &
    total_waiting_time ∈ ℕ &
    
    // Propriétés de sécurité fondamentales
    // (1) Les feux opposés ne peuvent pas être verts simultanément
    ∀d1, d2 · (d1 ∈ DIRECTIONS & d2 ∈ DIRECTIONS & 
              ((d1 = NORTH & d2 = EAST) or (d1 = NORTH & d2 = WEST) or
               (d1 = SOUTH & d2 = EAST) or (d1 = SOUTH & d2 = WEST))) ⇒
              ¬(traffic_lights(d1) = GREEN & traffic_lights(d2) = GREEN) &
    
    // (2) Les piétons ne peuvent traverser que quand les voitures correspondantes sont arrêtées
    ∀d · (d ∈ DIRECTIONS & pedestrian_signals(d) = WALK) ⇒ 
          (traffic_lights(d) = RED)

INITIALISATION
    // Initialisation des variables
    traffic_lights := {NORTH↦RED, SOUTH↦RED, EAST↦RED, WEST↦RED} ||
    pedestrian_signals := {NORTH↦DONT_WALK, SOUTH↦DONT_WALK, EAST↦DONT_WALK, WEST↦DONT_WALK} ||
    current_phase := PHASE_NS ||
    timer := 0 ||
    queue_length := {NORTH↦0, SOUTH↦0, EAST↦0, WEST↦0} ||
    waiting_time := {NORTH↦0, SOUTH↦0, EAST↦0, WEST↦0} ||
    total_waiting_time := 0

EVENTS
    // Événement pour simuler l'arrivée d'un véhicule
    VehicleArrives =
        ANY dir WHERE
            dir ∈ DIRECTIONS
        THEN
            queue_length(dir) := queue_length(dir) + 1
        END;
    
    // Événement pour faire avancer le temps
    Tick =
        BEGIN
            timer := timer + 1 ||
            // Incrémenter le temps d'attente pour les files non vides
            waiting_time := λd·(d ∈ DIRECTIONS | 
                             IF queue_length(d) > 0 
                             THEN waiting_time(d) + queue_length(d)
                             ELSE waiting_time(d)
                             END) ||
            // Mise à jour du temps d'attente total
            total_waiting_time := total_waiting_time + 
                                 SIGMA(d).(d ∈ DIRECTIONS | queue_length(d))
        END;
    
    // Passage de la phase Nord-Sud à la transition
    SwitchFromNS_to_Transition =
        WHEN
            current_phase = PHASE_NS &
            timer >= phase_duration(current_phase)  /* Durée calculée par l'algorithme d'optimisation */
        THEN
            current_phase := TRANSITION_NS_TO_EW ||
            traffic_lights := {NORTH↦YELLOW, SOUTH↦YELLOW, EAST↦RED, WEST↦RED} ||
            timer := 0
        END;
    
    // Passage de la transition à la phase Est-Ouest
    SwitchFromTransition_to_EW =
        WHEN
            current_phase = TRANSITION_NS_TO_EW &
            timer >= yellow_duration  /* Constante pour la durée du feu jaune */
        THEN
            current_phase := PHASE_EW ||
            traffic_lights := {NORTH↦RED, SOUTH↦RED, EAST↦GREEN, WEST↦GREEN} ||
            pedestrian_signals := {NORTH↦DONT_WALK, SOUTH↦DONT_WALK, EAST↦WALK, WEST↦WALK} ||
            timer := 0
        END;
    
    // Passage de la phase Est-Ouest à la transition
    SwitchFromEW_to_Transition =
        WHEN
            current_phase = PHASE_EW &
            timer >= phase_duration(current_phase)  /* Durée calculée par l'algorithme d'optimisation */
        THEN
            current_phase := TRANSITION_EW_TO_NS ||
            traffic_lights := {NORTH↦RED, SOUTH↦RED, EAST↦YELLOW, WEST↦YELLOW} ||
            pedestrian_signals := {NORTH↦DONT_WALK, SOUTH↦DONT_WALK, EAST↦DONT_WALK, WEST↦DONT_WALK} ||
            timer := 0
        END;
    
    // Passage de la transition à la phase Nord-Sud
    SwitchFromTransition_to_NS =
        WHEN
            current_phase = TRANSITION_EW_TO_NS &
            timer >= yellow_duration  /* Constante pour la durée du feu jaune */
        THEN
            current_phase := PHASE_NS ||
            traffic_lights := {NORTH↦GREEN, SOUTH↦GREEN, EAST↦RED, WEST↦RED} ||
            pedestrian_signals := {NORTH↦WALK, SOUTH↦WALK, EAST↦DONT_WALK, WEST↦DONT_WALK} ||
            timer := 0
        END;
    
    // Événement pour les véhicules qui passent le feu vert
    VehiclesDeparture =
        ANY dir, num WHERE
            dir ∈ DIRECTIONS &
            traffic_lights(dir) = GREEN &
            num ∈ 1‥queue_length(dir)  // Nombre de véhicules qui passent
        THEN
            queue_length(dir) := queue_length(dir) - num
        END;
    
    // Événement pour le calcul optimal de la durée des phases
    OptimizePhases =
        /* Cet événement abstrait modélise le calcul des durées optimales
           basé sur les longueurs de files et temps d'attente */
        ANY ns_duration, ew_duration WHERE
            ns_duration ∈ MIN_PHASE_DURATION‥MAX_PHASE_DURATION &
            ew_duration ∈ MIN_PHASE_DURATION‥MAX_PHASE_DURATION &
            // Règle d'optimisation (à préciser dans l'implémentation)
            ns_duration ∝ (queue_length(NORTH) + queue_length(SOUTH)) &
            ew_duration ∝ (queue_length(EAST) + queue_length(WEST))
        THEN
            phase_duration := {PHASE_NS↦ns_duration, PHASE_EW↦ew_duration,
                             TRANSITION_NS_TO_EW↦yellow_duration, TRANSITION_EW_TO_NS↦yellow_duration}
        END

END
