-- P-40a (#220) — índice servidor del catálogo Dart y ruta recomendada completa.
--
-- Verificado contra producción (MCP supabase, solo lectura):
--   * `LessonCatalog.catalog` tiene 140 lecciones (20 por nivel PRE-A1…C2).
--   * Los títulos coinciden con `scenarios` (language_id = 1) en PRE-A1…B1 y
--     C2; B2 y C1 divergieron (ver docs/runbooks/CURRICULUM_ALIGNMENT.md).
--   * Sin un índice del catálogo, el servidor no puede ordenar las lecciones
--     que la Ruta muestra en B2/C1: la ruta quedaría coja justo donde el
--     contenido de BD ya no representa el currículo de la app.
--
-- Este índice es de solo lectura para las funciones SECURITY DEFINER: la Ruta
-- sigue leyendo `LessonCatalog` para pintar y este espejo solo decide el orden.

create table if not exists public.lesson_catalog_index (
  lesson_id text primary key,
  level text not null,
  title text not null,
  category text not null default 'daily',
  updated_at timestamptz not null default now()
);

comment on table public.lesson_catalog_index is
  'P-40a (#220): espejo de LessonCatalog.catalog (id, nivel, título, categoría) para que el servidor calcule la ruta recomendada sobre las mismas lecciones que muestra la Ruta. Sin acceso de cliente (RLS sin políticas); solo lo leen funciones SECURITY DEFINER.';

alter table public.lesson_catalog_index enable row level security;

update public.scenarios s
   set lesson_key = null
 where s.lesson_key is not null
   and s.lesson_key not in (
     'prea1_hello_hello','prea1_my_name_is','prea1_yes_no','prea1_please_thank_you',
     'prea1_numbers_1_to_5','prea1_numbers_6_to_10','prea1_basic_colors','prea1_good_morning',
     'prea1_how_are_you','prea1_goodbye','prea1_my_family','prea1_body_words','prea1_food_words',
     'prea1_one_water_please','prea1_asking_for_help','prea1_i_dont_understand','prea1_days_of_week',
     'prea1_weather_words','prea1_common_objects','prea1_this_is',
     'a1_ordering_coffee_at_a_cafe','a1_checking_into_a_hotel','a1_asking_for_street_directions',
     'a1_grocery_shopping_basics','a1_taking_a_city_taxi','a1_introducing_yourself_to_a_neighbor',
     'a1_ordering_pizza_for_pickup','a1_buying_clothes_at_a_shop','a1_talking_about_daily_routine',
     'a1_discussing_weather_and_time','a1_doctor_clinic_reception_check_in','a1_visiting_a_pet_shop',
     'a1_talking_about_hobbies','a1_birthday_party_wish_gift','a1_buying_bus_tickets',
     'a1_renting_a_city_bike','a1_asking_for_pharmacy_help','a1_smartphone_basics_setup',
     'a1_showing_family_photo_album','a1_ordering_bakery_breakfast',
     'a2_handling_restaurant_order_issue','a2_returning_a_purchased_clothing_item','a2_booking_a_guided_city_tour',
     'a2_asking_advice_for_a_mild_cold','a2_handling_train_delays_at_station','a2_opening_a_bank_checking_account',
     'a2_signing_up_for_gym_membership','a2_renting_a_compact_car','a2_doctor_consultation_for_sprained_ankle',
     'a2_setting_roommate_house_rules','a2_describing_your_job_responsibilities','a2_shopping_for_a_birthday_gift',
     'a2_explaining_a_simple_recipe','a2_planning_a_weekend_trip','a2_historic_neighborhood_tour',
     'a2_reporting_a_lost_wallet','a2_hairdresser_appointment_styling','a2_inquiring_about_music_festival',
     'a2_getting_a_public_library_card','a2_ordering_food_delivery_by_phone',
     'b1_job_interview_strengths_weaknesses','b1_describing_past_work_challenges','b1_apartment_viewing_with_landlord',
     'b1_troubleshooting_software_bug_with_it','b1_customer_service_refund_negotiation','b1_discussing_favorite_movies_themes',
     'b1_planning_a_group_trip_budget','b1_weekly_office_status_update_meeting','b1_resolving_missing_package_shipping_issue',
     'b1_setting_fitness_health_targets','b1_volunteering_for_community_park_cleanup','b1_organizing_a_surprise_birthday_party',
     'b1_discussing_long_term_career_ambitions','b1_resolving_workplace_miscommunication','b1_adopting_sustainable_daily_habits',
     'b1_designing_remote_work_home_office','b1_selecting_university_elective_courses','b1_bargaining_price_at_flea_market',
     'b1_handling_flight_schedule_changes','b1_comparing_cultural_traditions_holidays',
     'b2_senior_tech_developer_architecture_interview','b2_pitching_a_new_product_feature','b2_debating_remote_vs_hybrid_work_policies',
     'b2_salary_equity_package_negotiation','b2_expressing_nuanced_opinions_in_debates','b2_modern_art_gallery_exhibition_critique',
     'b2_managing_a_disappointed_key_client','b2_requesting_a_project_deadline_extension','b2_debating_environmental_energy_policies',
     'b2_pitching_a_startup_idea_to_vc_investors','b2_navigating_complex_government_bureaucracy','b2_discussing_ethics_in_artificial_intelligence',
     'b2_handling_team_conflict_as_a_manager','b2_handling_an_emergency_situation_abroad','b2_commercial_real_estate_investment_pitch',
     'b2_public_speaking_keynote_preparation','b2_corporate_crisis_mitigation_strategy','b2_analyzing_media_bias_news_credibility',
     'b2_strategic_career_pivot_discussion','b2_sports_performance_data_analytics',
     'c1_contract_scope_royalty_negotiation','c1_academic_debate_on_macroeconomic_policy','c1_executive_board_strategy_review',
     'c1_philosophical_ethics_ai_consciousness','c1_literary_analysis_of_post_war_fiction','c1_cross_border_mergers_acquisitions_strategy',
     'c1_geopolitical_energy_security_strategy','c1_intellectual_property_litigation_settlement','c1_complex_medical_case_consultation',
     'c1_distributed_cloud_systems_architecture_review','c1_international_diplomatic_protocol_crisis','c1_crisis_public_relations_press_conference',
     'c1_venture_capital_due_diligence_defense','c1_global_climate_policy_accord_negotiations','c1_enterprise_cloud_security_audit_review',
     'c1_corporate_governance_ethics_investigation','c1_higher_education_structural_reform_debate','c1_scientific_peer_review_defense',
     'c1_global_franchise_expansion_strategy','c1_bioethics_of_human_gene_editing',
     'c2_diplomatic_summit_on_multilateral_treaties','c2_supreme_court_constitutional_argument','c2_epistemology_theoretical_consciousness',
     'c2_peer_review_defense_of_quantum_physics_research','c2_post_modernist_literary_deconstruction','c2_central_bank_monetary_policy_summit',
     'c2_cyber_warfare_sovereign_state_threat_analysis','c2_high_stakes_international_trade_arbitration','c2_complex_corporate_restructuring_solvency',
     'c2_fine_art_authentication_provenance_debate','c2_ethnomusicology_archaeoacoustic_research','c2_astro_physics_dark_energy_cosmological_models',
     'c2_international_human_rights_digital_charter','c2_neuro_linguistic_bci_speech_synthesis','c2_arbitral_award_international_enforcement',
     'c2_executive_crisis_address_to_global_stakeholders','c2_advanced_zk_stark_distributed_consensus',
     'c2_geo_engineering_ethics_solar_radiation_managemen','c2_post_quantum_cryptographic_standard_migration',
     'c2_structural_analysis_of_late_beethoven_quartets'
   );

-- Las lecciones ya mapeadas en BD aportan título/categoría reales.
insert into public.lesson_catalog_index (lesson_id, level, title, category)
select distinct on (lesson_key)
       lesson_key, difficulty_level, title, coalesce(category, 'daily')
  from public.scenarios
 where lesson_key is not null
   and language_id = 1
   and is_active
   and deleted_at is null
 order by lesson_key, (review_status = 'approved') desc, created_at asc
on conflict (lesson_id) do update
   set level = excluded.level,
       title = excluded.title,
       category = excluded.category,
       updated_at = now();

-- B2 y C1 divergieron entre el catálogo Dart y `scenarios`: se siembran desde
-- el catálogo para que la Ruta pueda ordenarlos. C2: las 4 lecciones que no
-- tienen escenario en BD.
insert into public.lesson_catalog_index (lesson_id, level, title, category)
values
  ('b2_senior_tech_developer_architecture_interview', 'B2', 'Senior Tech Developer Architecture Interview', 'technology'),
  ('b2_pitching_a_new_product_feature', 'B2', 'Pitching a New Product Feature', 'business'),
  ('b2_debating_remote_vs_hybrid_work_policies', 'B2', 'Debating Remote vs Hybrid Work Policies', 'business'),
  ('b2_salary_equity_package_negotiation', 'B2', 'Salary & Equity Package Negotiation', 'business'),
  ('b2_expressing_nuanced_opinions_in_debates', 'B2', 'Expressing Nuanced Opinions in Debates', 'history'),
  ('b2_modern_art_gallery_exhibition_critique', 'B2', 'Modern Art Gallery Exhibition Critique', 'art'),
  ('b2_managing_a_disappointed_key_client', 'B2', 'Managing a Disappointed Key Client', 'business'),
  ('b2_requesting_a_project_deadline_extension', 'B2', 'Requesting a Project Deadline Extension', 'business'),
  ('b2_debating_environmental_energy_policies', 'B2', 'Debating Environmental Energy Policies', 'science'),
  ('b2_pitching_a_startup_idea_to_vc_investors', 'B2', 'Pitching a Startup Idea to VC Investors', 'business'),
  ('b2_navigating_complex_government_bureaucracy', 'B2', 'Navigating Complex Government Bureaucracy', 'history'),
  ('b2_discussing_ethics_in_artificial_intelligence', 'B2', 'Discussing Ethics in Artificial Intelligence', 'technology'),
  ('b2_handling_team_conflict_as_a_manager', 'B2', 'Handling Team Conflict as a Manager', 'business'),
  ('b2_handling_an_emergency_situation_abroad', 'B2', 'Handling an Emergency Situation Abroad', 'travel'),
  ('b2_commercial_real_estate_investment_pitch', 'B2', 'Commercial Real Estate Investment Pitch', 'business'),
  ('b2_public_speaking_keynote_preparation', 'B2', 'Public Speaking Keynote Preparation', 'art'),
  ('b2_corporate_crisis_mitigation_strategy', 'B2', 'Corporate Crisis Mitigation Strategy', 'business'),
  ('b2_analyzing_media_bias_news_credibility', 'B2', 'Analyzing Media Bias & News Credibility', 'history'),
  ('b2_strategic_career_pivot_discussion', 'B2', 'Strategic Career Pivot Discussion', 'business'),
  ('b2_sports_performance_data_analytics', 'B2', 'Sports Performance Data Analytics', 'sports'),
  ('c1_contract_scope_royalty_negotiation', 'C1', 'Contract Scope & Royalty Negotiation', 'business'),
  ('c1_academic_debate_on_macroeconomic_policy', 'C1', 'Academic Debate on Macroeconomic Policy', 'history'),
  ('c1_executive_board_strategy_review', 'C1', 'Executive Board Strategy Review', 'business'),
  ('c1_philosophical_ethics_ai_consciousness', 'C1', 'Philosophical Ethics & AI Consciousness', 'history'),
  ('c1_literary_analysis_of_post_war_fiction', 'C1', 'Literary Analysis of Post-War Fiction', 'art'),
  ('c1_cross_border_mergers_acquisitions_strategy', 'C1', 'Cross-Border Mergers & Acquisitions Strategy', 'business'),
  ('c1_geopolitical_energy_security_strategy', 'C1', 'Geopolitical Energy Security Strategy', 'science'),
  ('c1_intellectual_property_litigation_settlement', 'C1', 'Intellectual Property Litigation Settlement', 'business'),
  ('c1_complex_medical_case_consultation', 'C1', 'Complex Medical Case Consultation', 'science'),
  ('c1_distributed_cloud_systems_architecture_review', 'C1', 'Distributed Cloud Systems Architecture Review', 'technology'),
  ('c1_international_diplomatic_protocol_crisis', 'C1', 'International Diplomatic Protocol & Crisis', 'history'),
  ('c1_crisis_public_relations_press_conference', 'C1', 'Crisis Public Relations Press Conference', 'business'),
  ('c1_venture_capital_due_diligence_defense', 'C1', 'Venture Capital Due Diligence Defense', 'business'),
  ('c1_global_climate_policy_accord_negotiations', 'C1', 'Global Climate Policy Accord Negotiations', 'science'),
  ('c1_enterprise_cloud_security_audit_review', 'C1', 'Enterprise Cloud Security Audit Review', 'technology'),
  ('c1_corporate_governance_ethics_investigation', 'C1', 'Corporate Governance & Ethics Investigation', 'business'),
  ('c1_higher_education_structural_reform_debate', 'C1', 'Higher Education Structural Reform Debate', 'history'),
  ('c1_scientific_peer_review_defense', 'C1', 'Scientific Peer Review Defense', 'science'),
  ('c1_global_franchise_expansion_strategy', 'C1', 'Global Franchise Expansion Strategy', 'business'),
  ('c1_bioethics_of_human_gene_editing', 'C1', 'Bioethics of Human Gene Editing', 'science'),
  ('c2_diplomatic_summit_on_multilateral_treaties', 'C2', 'Diplomatic Summit on Multilateral Treaties', 'history'),
  ('c2_supreme_court_constitutional_argument', 'C2', 'Supreme Court Constitutional Argument', 'history'),
  ('c2_epistemology_theoretical_consciousness', 'C2', 'Epistemology & Theoretical Consciousness', 'science'),
  ('c2_peer_review_defense_of_quantum_physics_research', 'C2', 'Peer Review Defense of Quantum Physics Research', 'science')
on conflict (lesson_id) do nothing;

create or replace function public.refresh_recommended_path(p_user_id uuid default null)
returns jsonb
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_uid uuid := coalesce(p_user_id, auth.uid());
  v_role text := coalesce(auth.role(), 'service_role');
  v_level text;
  v_language_id integer;
  v_interests text[] := '{}'::text[];
  v_weak_terms text[] := '{}'::text[];
  v_daily_minutes integer;
  v_path jsonb;
begin
  if v_uid is null then
    raise exception 'No autorizado';
  end if;
  if v_role not in ('service_role', 'authenticated')
     or (v_role = 'authenticated' and auth.uid() is distinct from v_uid) then
    raise exception 'No autorizado';
  end if;

  select c.code, lp.language_id
    into v_level, v_language_id
    from public.user_language_profiles lp
    left join public.cefr_levels c on c.id = lp.cefr_level_id
   where lp.user_id = v_uid
   order by lp.updated_at desc nulls last, lp.id
   limit 1;
  v_level := coalesce(v_level, 'A1');
  v_language_id := coalesce(v_language_id, 1);

  select coalesce(array_agg(distinct term order by term), '{}'::text[])
    into v_interests
    from (
      select lower(btrim(i)) as term
        from public.user_settings s,
             unnest(coalesce(s.interests, '{}'::text[])) as i
       where s.user_id = v_uid
      union all
      select lower(btrim(a))
        from public.user_ai_profiles p,
             unnest(coalesce(p.focus_areas, '{}'::text[])) as a
       where p.user_id = v_uid
    ) t
   where term <> '';

  select coalesce(array_agg(distinct term), '{}'::text[])
    into v_weak_terms
    from (
      select (regexp_matches(
                lower(coalesce(e.last_original, '') || ' ' ||
                      coalesce(e.normalized_corrected, '')),
                '[a-z]{4,}', 'g'
              ))[1] as term
        from public.user_recurring_errors e
       where e.user_id = v_uid
         and e.occurrences >= 2
       order by e.occurrences desc
       limit 12
    ) t;

  select s.daily_goal_minutes
    into v_daily_minutes
    from public.user_settings s
   where s.user_id = v_uid;
  v_daily_minutes := coalesce(v_daily_minutes, 15);

  with base as (
    select c.lesson_id,
           s.id as scenario_id,
           c.title,
           c.level,
           c.category,
           coalesce(s.estimated_minutes, 15) as minutes,
           (
             exists (
               select 1
                 from public.lesson_progress lp
                where lp.user_id = v_uid
                  and lp.lesson_id = c.lesson_id
                  and lp.status = 'passed'
             )
             or exists (
               select 1
                 from public.user_scenario_goals g
                where g.user_id = v_uid
                  and g.is_completed
                  and (g.scenario_id = c.lesson_id
                       or (s.id is not null and g.scenario_id = s.id::text))
                group by g.scenario_id, s.goals
               having coalesce(jsonb_array_length(s.goals), 0) > 0
                  and public.lesson_completion_passed(
                        count(distinct g.goal_id)::integer,
                        coalesce(jsonb_array_length(s.goals), 0)
                      )
             )
           ) as completed,
           (
             select count(*)
               from unnest(v_interests) as i
              where strpos(
                      lower(c.title || ' ' || coalesce(s.description, '') || ' ' ||
                            c.category || ' ' || coalesce(s.main_objective, '')),
                      i) > 0
           ) as interest_hits,
           (
             select count(*)
               from unnest(v_weak_terms) as w
              where strpos(
                      lower(c.title || ' ' || coalesce(s.description, '') || ' ' ||
                            c.category),
                      w) > 0
           ) as error_hits
      from public.lesson_catalog_index c
      left join lateral (
        select sc.id, sc.description, sc.main_objective, sc.goals,
               sc.estimated_minutes
          from public.scenarios sc
         where sc.lesson_key = c.lesson_id
           and sc.language_id = v_language_id
           and sc.is_active
           and sc.deleted_at is null
         order by (sc.created_by_user_id is null) desc, sc.created_at asc, sc.id
         limit 1
      ) s on true
     where c.level = v_level
  ),
  ranked as (
    select base.*,
           case
             when base.completed then 'review'
             when base.error_hits > 0 then 'recurring_error'
             when base.interest_hits > 0 then 'interest'
             else 'next'
           end as reason,
           row_number() over (
             order by base.completed asc,
                      base.interest_hits desc,
                      base.error_hits desc,
                      abs(base.minutes - v_daily_minutes) asc,
                      base.title asc,
                      base.lesson_id asc
           ) as position
      from base
  )
  select coalesce(
           jsonb_agg(
             jsonb_build_object(
               'scenario_id', ranked.scenario_id,
               'lesson_key', ranked.lesson_id,
               'title', ranked.title,
               'level', ranked.level,
               'category', ranked.category,
               'estimated_minutes', ranked.minutes,
               'position', ranked.position,
               'reason', ranked.reason
             ) order by ranked.position
           ),
           '[]'::jsonb
         )
    into v_path
    from ranked
   where ranked.position <= 20;

  insert into public.user_ai_profiles (
    user_id,
    pedagogical_summary,
    tutor_prompt_instructions,
    recommended_path_scenarios
  )
  values (v_uid, '', '', v_path)
  on conflict (user_id) do update
     set recommended_path_scenarios = excluded.recommended_path_scenarios,
         updated_at = now()
   where public.user_ai_profiles.recommended_path_scenarios
         is distinct from excluded.recommended_path_scenarios;

  return v_path;
end;
$function$;

comment on function public.refresh_recommended_path(uuid) is
  'P-40a (#220): calcula y persiste la ruta recomendada del alumno (nivel real, intereses, errores recurrentes y lecciones superadas) sobre el catálogo y los escenarios existentes. Sin llamadas de IA; idempotente.';
