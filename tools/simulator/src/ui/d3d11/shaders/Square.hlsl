cbuffer SquareData : register(b0)
{
    uint g_buffer_width;
    uint g_buffer_height;
    float2 _padding;
}

StructuredBuffer<float> g_input_buffer : register(t0);
RWStructuredBuffer<float> g_output_buffer : register(u0);

[numthreads(8, 8, 1)]
void CSSquare(uint3 dispatch_thread_id : SV_DispatchThreadID)
{
    if (dispatch_thread_id.x < g_buffer_width && dispatch_thread_id.y < g_buffer_height)
    {
        uint index = dispatch_thread_id.x + dispatch_thread_id.y * g_buffer_width;
        float value = g_input_buffer[index];
        g_output_buffer[index] = value * value;
    }
}