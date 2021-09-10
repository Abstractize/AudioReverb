using System;
using System.Collections.Generic;
using NAudio.Wave;

namespace DotnetRev
{
    class Program
    {
        static void Main(string[] args)
        {
            short[] newWavData;
            int rate;
            int bits;
            int channels;
            using (WaveFileReader reader = new WaveFileReader("../../../input/desong.wav"))
            {
                rate = reader.WaveFormat.SampleRate;
                bits = reader.WaveFormat.BitsPerSample;
                channels = reader.WaveFormat.Channels;

                //Assert.AreEqual(16, reader.WaveFormat.BitsPerSample, "Only works with 16 bit audio");
                List<short> kValues = new List<short>();
                short k = 2500;
                float alpha = 0.60f;

                byte[] buffer = new byte[reader.Length];
                int read = reader.Read(buffer, 0, buffer.Length);
                short[] sampleBuffer = new short[read / 2];
                Buffer.BlockCopy(buffer, 0, sampleBuffer, 0, read);
                for (int i = 0; i < sampleBuffer.Length; i++)
                {
                    short sample = sampleBuffer[i];
                    short oldSample = 0;
                    if (kValues.Count > k)
                        oldSample = kValues[i - k];
                    short newSample = (short) ((1 - alpha) * sample + alpha * oldSample);
                    kValues.Add(newSample);
                }

                newWavData = kValues.ToArray();
            }
            using (WaveFileWriter writer = new WaveFileWriter("../../../output/desong.wav", new WaveFormat(rate, bits, channels)))
            {
                byte[] buffer = new byte[newWavData.Length * 2];
                Buffer.BlockCopy(newWavData, 0, buffer, 0, newWavData.Length * 2);
                writer.Write(buffer, 0, buffer.Length);
            }
        }
    }
}
