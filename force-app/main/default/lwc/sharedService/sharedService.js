// protocolService.js
const protocolData = {
    isProtocolSubmitted: false
};

const setProtocolSubmitted = (value) => {
    protocolData.isProtocolSubmitted = value;
};

const getProtocolSubmitted = () => {
    return protocolData.isProtocolSubmitted;
};

export { setProtocolSubmitted, getProtocolSubmitted };