# frozen_string_literal: true

require "spec_helper"

RSpec.describe Skia::Matrix do
  describe ".identity" do
    it "creates identity matrix" do
      m = described_class.identity
      expect(m.identity?).to be true
      expect(m.scale_x).to eq(1.0)
      expect(m.scale_y).to eq(1.0)
    end
  end

  describe ".translate" do
    it "creates translation matrix" do
      m = described_class.translate(10, 20)
      expect(m.trans_x).to eq(10)
      expect(m.trans_y).to eq(20)
    end
  end

  describe ".scale" do
    it "creates scale matrix" do
      m = described_class.scale(2, 3)
      expect(m.scale_x).to eq(2)
      expect(m.scale_y).to eq(3)
    end

    it "creates uniform scale with single argument" do
      m = described_class.scale(2)
      expect(m.scale_x).to eq(2)
      expect(m.scale_y).to eq(2)
    end
  end

  describe ".rotate" do
    it "creates rotation matrix" do
      m = described_class.rotate(90)
      expect(m.scale_x).to be_within(0.0001).of(0)
      expect(m.skew_x).to be_within(0.0001).of(-1)
    end
  end

  describe "#*" do
    it "multiplies matrices" do
      t = described_class.translate(10, 0)
      s = described_class.scale(2, 2)
      result = t * s
      expect(result.scale_x).to eq(2)
      expect(result.trans_x).to eq(10)
    end
  end

  describe "#transform_point" do
    it "transforms a point" do
      m = described_class.translate(10, 20)
      p = Skia::Point.new(5, 5)
      result = m.transform_point(p)
      expect(result.x).to eq(15)
      expect(result.y).to eq(25)
    end
  end
end
