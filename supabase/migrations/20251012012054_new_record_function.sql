CREATE OR REPLACE FUNCTION public.new_exercise(
    p_start_time timestamptz,
    p_end_time timestamptz,
    p_description varchar(100) DEFAULT '',
    p_user_id uuid DEFAULT NULL  -- 可選，用於 service key 呼叫
)
RETURNS int  -- 回傳更新後的 HP
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id uuid := COALESCE(p_user_id, auth.uid());
    v_pet_id int;
    v_new_hp int;
BEGIN
    -- 安全檢查：auth.uid() 不可為空
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Unauthorized: user not logged in';
    END IF;

    -- 寫入運動紀錄
    INSERT INTO public.records (id, user_id, start_time, end_time, description)
    VALUES (gen_random_uuid(), v_user_id, p_start_time, p_end_time, p_description);

    -- 取得該使用者的寵物
    SELECT id INTO v_pet_id FROM public.pets WHERE user_id = v_user_id;

    IF v_pet_id IS NULL THEN
        RAISE EXCEPTION 'No pet found for user %', v_user_id;
    END IF;

    -- 提升 HP，假設上限為 100
    UPDATE public.pets
    SET hp = LEAST(hp + 10, 100),
        updated_at = NOW()
    WHERE id = v_pet_id
    RETURNING hp INTO v_new_hp;

    -- 依 HP 門檻更新外觀
    -- 外觀分級：level 1: 80-100, level 2: 60-79, level 3: 30-59, level 4: 0-29
    -- 回傳更新後的 HP
    RETURN v_new_hp;
END;
$$;

-- 權限設定：僅讓 authenticated 使用
-- REVOKE ALL ON FUNCTION public.new_exercise(timestamptz, timestamptz, varchar, uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.new_exercise(timestamptz, timestamptz, varchar, uuid) TO authenticated, anon;
