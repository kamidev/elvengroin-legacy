#define DIRECT3D12
#define STAGE_VERT

#define VL_PosNorTanUv0Col
#include "shadows_lit_resources.hlsl"

VSOutput VS_MAIN(VSInput Input, uint instance_id : SV_InstanceID)
{
    INIT_MAIN;
    VSOutput Out;
    Out.InstanceID = instance_id;
    Out.UV = unpack2Floats(Input.UV);

    ByteAddressBuffer instance_transform_buffer = ResourceDescriptorHeap[g_instance_data_buffer_index];
    uint instanceIndex = instance_id + g_start_instance_location;
    InstanceData instance = instance_transform_buffer.Load<InstanceData>(instanceIndex * sizeof(InstanceData));

    float4x4 tempMat = mul(g_proj_view_mat, instance.worldMat);
    Out.Position = mul(tempMat, float4(Input.Position.xyz, 1.0f));

    RETURN(Out);
}
