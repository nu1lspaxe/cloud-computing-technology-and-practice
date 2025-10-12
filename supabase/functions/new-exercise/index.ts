import { createClient } from "@supabase/supabase-js"
import "@supabase/functions-js/edge-runtime.d.ts"

// 初始化 Supabase client (使用 Service Role Key，因為在 Edge Function 內呼叫 SQL function)
const supabaseUrl = Deno.env.get("SUPABASE_URL")!
const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
const supabase = createClient(supabaseUrl, supabaseKey)

Deno.serve(async (req) => {
  try {
    const { start_time, end_time, description, user_id } = await req.json()

    if (!start_time || !end_time || !user_id) {
      return new Response(JSON.stringify({ error: "Missing parameters" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      })
    }

    // 呼叫 SQL function public.new_exercise
    const { data, error } = await supabase
      .rpc("new_exercise", {
        "p_start_time": start_time,
        "p_end_time": end_time,
        "p_description": description,
        "p_user_id": user_id, // 後端必須傳 user_id，因為 Service Role Key 無法取得 auth.uid()
      })

    if (error) {
      return new Response(JSON.stringify({ error: error.message }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      })
    }

    return new Response(JSON.stringify({ message: `User ${user_id}'s pet hp has updated!`, new_hp: data }), {
      headers: { "Content-Type": "application/json" },
    })
  } catch (err) {
    const message = err instanceof Error ? err.message : "Unknown error"
    return new Response(JSON.stringify({ error: message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    })
  }
})
