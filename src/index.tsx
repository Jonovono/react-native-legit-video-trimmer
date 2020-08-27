import { NativeModules } from 'react-native';

type LegitVideoTrimmerType = {
  multiply(a: number, b: number): Promise<number>;
};

const { LegitVideoTrimmer } = NativeModules;

export default LegitVideoTrimmer as LegitVideoTrimmerType;
