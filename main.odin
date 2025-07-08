package main

import fmt "core:fmt"
import m "core:math/linalg/hlsl"
import rl "vendor:raylib"
import rand "core:math/rand"

Paddle :: struct {
    p : m.float2,
    w : f32,
    h : f32,
}

Ball :: struct {
    p : m.float2,
    v : m.float2,
    radius : f32,
}

player1 : Paddle
player2 : Paddle

ball : Ball

player1_score : i32 = 0
player2_score : i32 = 0
game_paused : bool = false

draw_paddle :: proc(paddle: Paddle) {
    rl.DrawRectangle(i32(paddle.p.x - paddle.w/2), i32(paddle.p.y - paddle.h/2), i32(paddle.w), i32(paddle.h), rl.WHITE)
}

draw_ball :: proc(ball: Ball) {
    rl.DrawCircle(i32(ball.p.x), i32(ball.p.y), ball.radius, rl.WHITE)
}

update_paddle_input :: proc(paddle: ^Paddle, up_key: rl.KeyboardKey, down_key: rl.KeyboardKey, window_height: i32) {
    paddle_speed : f32 = 400
    dt := rl.GetFrameTime()

    if rl.IsKeyDown(up_key) {
        paddle.p.y -= paddle_speed * dt
    }
    if rl.IsKeyDown(down_key) {
        paddle.p.y += paddle_speed * dt
    }

    // Keep paddle within screen bounds
    if paddle.p.y - paddle.h/2 < 0 {
        paddle.p.y = paddle.h/2
    }
    if paddle.p.y + paddle.h/2 > f32(window_height) {
        paddle.p.y = f32(window_height) - paddle.h/2
    }
}

check_ball_paddle_collision :: proc(ball: ^Ball, paddle: Paddle) -> bool {
    // Simple AABB collision detection
    ball_left := ball.p.x - ball.radius
    ball_right := ball.p.x + ball.radius
    ball_top := ball.p.y - ball.radius
    ball_bottom := ball.p.y + ball.radius

    paddle_left := paddle.p.x - paddle.w/2
    paddle_right := paddle.p.x + paddle.w/2
    paddle_top := paddle.p.y - paddle.h/2
    paddle_bottom := paddle.p.y + paddle.h/2

    return ball_right >= paddle_left && ball_left <= paddle_right &&
           ball_bottom >= paddle_top && ball_top <= paddle_bottom
}

update_ball :: proc(ball: ^Ball, player1: Paddle, player2: Paddle, window_width: i32, window_height: i32) -> (player1_scored: bool, player2_scored: bool) {
    dt := rl.GetFrameTime()

    // Move ball
    ball.p += ball.v * dt

    // Wall collision (top and bottom)
    if ball.p.y - ball.radius <= 0 || ball.p.y + ball.radius >= f32(window_height) {
        ball.v.y = -ball.v.y
        ball.p.y = m.clamp(ball.p.y, ball.radius, f32(window_height) - ball.radius)
    }

    // Paddle collision with improved physics
    if check_ball_paddle_collision(ball, player1) {
        ball.v.x = abs(ball.v.x)  // Ensure ball moves right
        ball.p.x = player1.p.x + player1.w/2 + ball.radius  // Push ball out of paddle

        // Add some angle based on where ball hits paddle
        hit_pos := (ball.p.y - player1.p.y) / (player1.h/2)  // -1 to 1
        ball.v.y += hit_pos * 100  // Add some vertical velocity
    }
    if check_ball_paddle_collision(ball, player2) {
        ball.v.x = -abs(ball.v.x)  // Ensure ball moves left
        ball.p.x = player2.p.x - player2.w/2 - ball.radius  // Push ball out of paddle

        // Add some angle based on where ball hits paddle
        hit_pos := (ball.p.y - player2.p.y) / (player2.h/2)  // -1 to 1
        ball.v.y += hit_pos * 100  // Add some vertical velocity
    }

    // Check for scoring
    if ball.p.x < 0 {
        return false, true  // Player 2 scored
    }
    if ball.p.x > f32(window_width) {
        return true, false  // Player 1 scored
    }

    return false, false
}

reset_ball :: proc(ball: ^Ball, window_width: i32, window_height: i32) {
    ball.p = {f32(window_width / 2), f32(window_height / 2)}
    // Randomize direction but keep consistent speed
    direction := rand.choice([]f32{-1, 1})
    ball.v = {300 * direction, rand.float32_range(-200, 200)}
}

main :: proc() {
    window_dim := m.int2{800, 600}
    rl.InitWindow(window_dim.x, window_dim.y, "raypong")
    rl.SetTargetFPS(60)
    is_running := true

    // Initialize paddles
    paddle_width : f32 = 20
    paddle_height : f32 = 100
    player1.p = {30, f32(window_dim.y / 2)}
    player1.w = paddle_width
    player1.h = paddle_height

    player2.p = {f32(window_dim.x) - 30, f32(window_dim.y / 2)}
    player2.w = paddle_width
    player2.h = paddle_height

    // Initialize ball
    ball.p = {f32(window_dim.x / 2), f32(window_dim.y / 2)}
    ball.v = m.float2{300, 200}  // Fixed velocity instead of random
    ball.radius = 10

    for is_running && !rl.WindowShouldClose() {
        // Handle pause
        if rl.IsKeyPressed(rl.KeyboardKey.SPACE) {
            game_paused = !game_paused
        }

        if !game_paused {
            // Update input
            update_paddle_input(&player1, rl.KeyboardKey.W, rl.KeyboardKey.S, window_dim.y)
            update_paddle_input(&player2, rl.KeyboardKey.UP, rl.KeyboardKey.DOWN, window_dim.y)

            // Update ball physics and check for scoring
            p1_scored, p2_scored := update_ball(&ball, player1, player2, window_dim.x, window_dim.y)
            if p1_scored {
                player1_score += 1
                reset_ball(&ball, window_dim.x, window_dim.y)
            }
            if p2_scored {
                player2_score += 1
                reset_ball(&ball, window_dim.x, window_dim.y)
            }
        }

        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)

        // Draw center line
        for y : i32 = 0; y < window_dim.y; y += 20 {
            rl.DrawRectangle(window_dim.x/2 - 2, y, 4, 10, rl.DARKGRAY)
        }

        // Draw game objects
        draw_paddle(player1)
        draw_paddle(player2)
        draw_ball(ball)

        // Draw scores
        score1_text := fmt.ctprintf("%d", player1_score)
        score2_text := fmt.ctprintf("%d", player2_score)
        rl.DrawText(score1_text, window_dim.x/4, 50, 48, rl.WHITE)
        rl.DrawText(score2_text, 3*window_dim.x/4, 50, 48, rl.WHITE)

        // Draw pause message
        if game_paused {
            pause_text : cstring = "PAUSED - Press SPACE to continue"
            text_width := rl.MeasureText(pause_text, 20)
            rl.DrawText(pause_text, window_dim.x/2 - text_width/2, window_dim.y/2, 20, rl.YELLOW)
        }

        // Draw controls
        rl.DrawText("Player 1: W/S", 10, window_dim.y - 60, 16, rl.DARKGRAY)
        rl.DrawText("Player 2: UP/DOWN", 10, window_dim.y - 40, 16, rl.DARKGRAY)
        rl.DrawText("SPACE: Pause", 10, window_dim.y - 20, 16, rl.DARKGRAY)

        rl.EndDrawing()
    }

    rl.CloseWindow()
}