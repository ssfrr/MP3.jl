using MP3

if VERSION >= v"0.5.0-dev+7720"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

# encoding and decoding can introduce some delay
DELAY_THRESHOLD = 1160

# write your own tests here
# @testset "Loading MP3" begin
#     reference = load(joinpath(dirname(@__FILE__), "Sour_Tennessee_Red_Sting.mp3"))
#     @test typeof(reference) == SampledSignals.SampleBuf{MP3.PCM16Sample,2,MP3.Hertz}
#     @test size(reference, 2) == 2
#     @test abs(size(reference, 1) - 245376) <= DELAY_THRESHOLD
#     @test reference.samplerate == 44100Hz
#     @test reference.samplerate == 44.1kHz
# end

@testset "Saving MP3" begin
    println("loading...")
    reference = load(joinpath(dirname(@__FILE__), "Sour_Tennessee_Red_Sting.mp3"))

    outpath = "$(tempname()).mp3"
    println("saving...")
    save(outpath, reference)
    println("loading again...")
    audio = load(outpath)
    @test size(audio) == size(reference)
    @test audio.samplerate == reference.samplerate

    println("samplerate")
    for samplerate in [8000, 11025, 12000, 16000, 22050, 24000, 32000, 44100, 48000]
        println("   samplerate: ", samplerate, ", saving...")
        save(outpath, reference; samplerate = samplerate)
        println("      loading...")
        audio = load(outpath)
        @test audio.samplerate == samplerate * Hz
    end

    println("bitrate")
    for bitrate in [96, 128, 160, 192, 224, 256, 320]
        println("   bitrate: ", bitrate)
        save(outpath, reference; bitrate = bitrate)
        audio = load(outpath)
        @test size(audio, 2) == size(reference, 2)
        @test abs(size(audio, 1) - size(reference, 1)) <= DELAY_THRESHOLD
    end

    println("left")
    save(outpath, reference[:, 1])
    audio = load(outpath)
    @test size(audio, 2) == 1

    print("right")
    save(outpath, reference[:, 2])
    audio = load(outpath)
    @test size(audio, 2) == 1

    print("left to stereo")
    save(outpath, reference[:, 1]; nchannels = 2)
    audio = load(outpath)
    @test size(audio, 2) == 2

    print("more1")
    f32 = map(Float32, reference)
    save(outpath, f32)
    audio = load(outpath)
    @test audio.samplerate == 44100Hz
    @test size(audio, 2) == size(reference, 2)
    @test abs(size(audio, 1) - size(reference, 1)) <= DELAY_THRESHOLD

    print("more2")
    f64 = map(Float32, reference)
    save(outpath, f64)
    @test audio.samplerate == 44100Hz
    @test size(audio, 2) == size(reference, 2)
    @test abs(size(audio, 1) - size(reference, 1)) <= DELAY_THRESHOLD
end
