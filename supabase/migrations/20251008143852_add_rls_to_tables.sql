-- Only allow anon/authenticated to read from public
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon, authenticated;

-- internal schema only for service_role
REVOKE ALL ON SCHEMA internal FROM anon, authenticated;

ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;

CREATE POLICY user_select_own_user 
    ON "public"."users"
    FOR SELECT 
    USING (auth.uid() = id);

-- Enable row level security
ALTER TABLE "public"."pets" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."pets" FORCE ROW LEVEL SECURITY;

-- Policy: users can only read their own pets
CREATE POLICY user_select_own_pets
    ON "public"."pets"
    FOR SELECT
    USING (user_id = auth.uid());

-- Policy: users can insert, update, and delete only their own pets
CREATE POLICY user_insert_own_pets ON "public"."pets" FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY user_update_own_pets ON "public"."pets" FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY user_delete_own_pets ON "public"."pets" FOR DELETE USING (user_id = auth.uid());

ALTER TABLE "internal"."accounts" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "internal"."accounts" FORCE ROW LEVEL SECURITY;

-- Policy: users can view their own account
CREATE POLICY user_select_own_account ON "internal"."accounts" FOR SELECT USING (user_id = auth.uid());

ALTER TABLE "public"."store_items" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."store_items" FORCE ROW LEVEL SECURITY;

-- Policy: anyone can view store items (read-only access)
CREATE POLICY public_select_store_items ON "public"."store_items" FOR SELECT USING (true);

-- Policy: only the service role can modify store items
CREATE POLICY service_insert_store_items ON "public"."store_items" FOR INSERT WITH CHECK (auth.role() = 'service_role');
CREATE POLICY service_update_store_items ON "public"."store_items" FOR UPDATE USING (auth.role() = 'service_role') WITH CHECK (auth.role() = 'service_role');
CREATE POLICY service_delete_store_items ON "public"."store_items" FOR DELETE USING (auth.role() = 'service_role');