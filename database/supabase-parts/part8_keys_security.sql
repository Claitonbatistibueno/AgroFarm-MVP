-- AgroFarm on Supabase — PART 4 of 8: keys, indexes, relations and security

-- Name: accounts_payable idx_16743_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.accounts_payable
    ADD CONSTRAINT idx_16743_primary PRIMARY KEY (payable_id);

-- Name: animal idx_16754_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT idx_16754_primary PRIMARY KEY (animal_id);

-- Name: animal_types idx_16763_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.animal_types
    ADD CONSTRAINT idx_16763_primary PRIMARY KEY (type_id);

-- Name: clients idx_16771_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT idx_16771_primary PRIMARY KEY (client_id);

-- Name: company idx_16782_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.company
    ADD CONSTRAINT idx_16782_primary PRIMARY KEY (company_id);

-- Name: daily_feeding idx_16797_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.daily_feeding
    ADD CONSTRAINT idx_16797_primary PRIMARY KEY (feeding_id);

-- Name: european_countries idx_16802_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.european_countries
    ADD CONSTRAINT idx_16802_primary PRIMARY KEY (country_id);

-- Name: events idx_16807_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.events
    ADD CONSTRAINT idx_16807_primary PRIMARY KEY (event_id);

-- Name: feed idx_16814_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.feed
    ADD CONSTRAINT idx_16814_primary PRIMARY KEY (feed_id);

-- Name: financial_categories idx_16823_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.financial_categories
    ADD CONSTRAINT idx_16823_primary PRIMARY KEY (category_id);

-- Name: health_records idx_16830_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.health_records
    ADD CONSTRAINT idx_16830_primary PRIMARY KEY (record_id);

-- Name: login_attempts idx_16840_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.login_attempts
    ADD CONSTRAINT idx_16840_primary PRIMARY KEY (id);

-- Name: lot idx_16845_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.lot
    ADD CONSTRAINT idx_16845_primary PRIMARY KEY (lot_id);

-- Name: lot_animals idx_16851_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.lot_animals
    ADD CONSTRAINT idx_16851_primary PRIMARY KEY (lot_id, animal_id);

-- Name: market_prices idx_16855_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.market_prices
    ADD CONSTRAINT idx_16855_primary PRIMARY KEY (price_id);

-- Name: medical_catalog idx_16863_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.medical_catalog
    ADD CONSTRAINT idx_16863_primary PRIMARY KEY (item_id);

-- Name: operational_costs idx_16875_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.operational_costs
    ADD CONSTRAINT idx_16875_primary PRIMARY KEY (cost_id);

-- Name: sales idx_16882_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT idx_16882_primary PRIMARY KEY (sale_id);

-- Name: suppliers idx_16889_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT idx_16889_primary PRIMARY KEY (supplier_id);

-- Name: users idx_16901_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.users
    ADD CONSTRAINT idx_16901_primary PRIMARY KEY (user_id);

-- Name: weighing idx_16911_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.weighing
    ADD CONSTRAINT idx_16911_primary PRIMARY KEY (weighing_id);

-- Name: weighing_operations idx_16921_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.weighing_operations
    ADD CONSTRAINT idx_16921_primary PRIMARY KEY (operation_id);

-- Name: idx_16743_category_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16743_category_id ON public.accounts_payable USING btree (category_id);

-- Name: idx_16743_supplier_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16743_supplier_id ON public.accounts_payable USING btree (supplier_id);

-- Name: idx_16754_country_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16754_country_id ON public.animal USING btree (country_id);

-- Name: idx_16754_tag_number; Type: INDEX; Schema: public; Owner: -

CREATE UNIQUE INDEX idx_16754_tag_number ON public.animal USING btree (tag_number);

-- Name: idx_16754_tag_number_2; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16754_tag_number_2 ON public.animal USING btree (tag_number);

-- Name: idx_16754_type_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16754_type_id ON public.animal USING btree (type_id);

-- Name: idx_16797_animal_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16797_animal_id ON public.daily_feeding USING btree (animal_id);

-- Name: idx_16797_feed_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16797_feed_id ON public.daily_feeding USING btree (feed_id);

-- Name: idx_16802_country_name; Type: INDEX; Schema: public; Owner: -

CREATE UNIQUE INDEX idx_16802_country_name ON public.european_countries USING btree (country_name);

-- Name: idx_16807_animal_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16807_animal_id ON public.events USING btree (animal_id);

-- Name: idx_16814_supplier_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16814_supplier_id ON public.feed USING btree (supplier_id);

-- Name: idx_16830_animal_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16830_animal_id ON public.health_records USING btree (animal_id);

-- Name: idx_16830_item_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16830_item_id ON public.health_records USING btree (item_id);

-- Name: idx_16840_idx_ip_time; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16840_idx_ip_time ON public.login_attempts USING btree (ip, attempted_at);

-- Name: idx_16845_name; Type: INDEX; Schema: public; Owner: -

CREATE UNIQUE INDEX idx_16845_name ON public.lot USING btree (name);

-- Name: idx_16851_animal_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16851_animal_id ON public.lot_animals USING btree (animal_id);

-- Name: idx_16863_supplier_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16863_supplier_id ON public.medical_catalog USING btree (supplier_id);

-- Name: idx_16875_animal_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16875_animal_id ON public.operational_costs USING btree (animal_id);

-- Name: idx_16875_lot_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16875_lot_id ON public.operational_costs USING btree (lot_id);

-- Name: idx_16882_animal_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16882_animal_id ON public.sales USING btree (animal_id);

-- Name: idx_16882_client_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16882_client_id ON public.sales USING btree (client_id);

-- Name: idx_16901_username; Type: INDEX; Schema: public; Owner: -

CREATE UNIQUE INDEX idx_16901_username ON public.users USING btree (username);

-- Name: idx_16911_animal_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16911_animal_id ON public.weighing USING btree (animal_id);

-- Name: idx_16911_fk_weighing_op; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16911_fk_weighing_op ON public.weighing USING btree (operation_id);

-- Name: accounts_payable accounts_payable_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.accounts_payable
    ADD CONSTRAINT accounts_payable_ibfk_1 FOREIGN KEY (supplier_id) REFERENCES public.suppliers(supplier_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: accounts_payable accounts_payable_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.accounts_payable
    ADD CONSTRAINT accounts_payable_ibfk_2 FOREIGN KEY (category_id) REFERENCES public.financial_categories(category_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: animal animal_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT animal_ibfk_1 FOREIGN KEY (type_id) REFERENCES public.animal_types(type_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: animal animal_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT animal_ibfk_2 FOREIGN KEY (country_id) REFERENCES public.european_countries(country_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: daily_feeding daily_feeding_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.daily_feeding
    ADD CONSTRAINT daily_feeding_ibfk_1 FOREIGN KEY (animal_id) REFERENCES public.animal(animal_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: daily_feeding daily_feeding_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.daily_feeding
    ADD CONSTRAINT daily_feeding_ibfk_2 FOREIGN KEY (feed_id) REFERENCES public.feed(feed_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: events events_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_ibfk_1 FOREIGN KEY (animal_id) REFERENCES public.animal(animal_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: feed feed_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.feed
    ADD CONSTRAINT feed_ibfk_1 FOREIGN KEY (supplier_id) REFERENCES public.suppliers(supplier_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: weighing fk_weighing_op; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.weighing
    ADD CONSTRAINT fk_weighing_op FOREIGN KEY (operation_id) REFERENCES public.weighing_operations(operation_id) ON UPDATE RESTRICT ON DELETE SET NULL;

-- Name: health_records health_records_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.health_records
    ADD CONSTRAINT health_records_ibfk_1 FOREIGN KEY (animal_id) REFERENCES public.animal(animal_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: health_records health_records_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.health_records
    ADD CONSTRAINT health_records_ibfk_2 FOREIGN KEY (item_id) REFERENCES public.medical_catalog(item_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: lot_animals lot_animals_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.lot_animals
    ADD CONSTRAINT lot_animals_ibfk_1 FOREIGN KEY (lot_id) REFERENCES public.lot(lot_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: lot_animals lot_animals_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.lot_animals
    ADD CONSTRAINT lot_animals_ibfk_2 FOREIGN KEY (animal_id) REFERENCES public.animal(animal_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: medical_catalog medical_catalog_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.medical_catalog
    ADD CONSTRAINT medical_catalog_ibfk_1 FOREIGN KEY (supplier_id) REFERENCES public.suppliers(supplier_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: operational_costs operational_costs_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.operational_costs
    ADD CONSTRAINT operational_costs_ibfk_1 FOREIGN KEY (lot_id) REFERENCES public.lot(lot_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: operational_costs operational_costs_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.operational_costs
    ADD CONSTRAINT operational_costs_ibfk_2 FOREIGN KEY (animal_id) REFERENCES public.animal(animal_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: sales sales_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_ibfk_1 FOREIGN KEY (animal_id) REFERENCES public.animal(animal_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: sales sales_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_ibfk_2 FOREIGN KEY (client_id) REFERENCES public.clients(client_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: weighing weighing_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.weighing
    ADD CONSTRAINT weighing_ibfk_1 FOREIGN KEY (animal_id) REFERENCES public.animal(animal_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- =========================================================
-- Security for Supabase
-- Supabase also exposes the public schema through its REST API (anon /
-- authenticated roles). AgroFarm connects straight to Postgres and does not
-- use that API, so it is locked: RLS on every table with no policies, and no
-- privileges for the API roles. The app's own connection (table owner) is not
-- affected.
-- =========================================================
DO $$
DECLARE t record;
BEGIN
  FOR t IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t.tablename);
  END LOOP;
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN
    EXECUTE 'REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon, authenticated';
    EXECUTE 'REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM anon, authenticated';
  END IF;
END $$;
