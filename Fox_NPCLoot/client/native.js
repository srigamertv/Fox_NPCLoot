exports('DataViewNativeGetEventData2', (eventGroup, index, argStructSize) => {
    const buffer = new ArrayBuffer(256);
    const view = new DataView(buffer);

    const success = Citizen.invokeNative(
        '0x57EC5FA4D4D6AFCA',
        eventGroup,
        index,
        view,
        argStructSize,
        Citizen.returnResultAnyway()
    );

    if (!success) {
        return null;
    }

    return new Int32Array(buffer, 0, argStructSize);
});
