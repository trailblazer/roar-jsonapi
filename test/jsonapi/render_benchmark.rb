require 'test_helper'
require 'minitest/benchmark'

$SAMPLES_PATH = File.expand_path('../../samples', __FILE__)

class JsonapiRenderBenchmark < MiniTest::Benchmark
  def self.bench_range
    bench_linear(2, 8, 2)
  end

  def bench_render
    assert_performance_constant do |n|
      n.times do |i|
        # simulates Rails auto-reloading
        load File.join($SAMPLES_PATH, 'document_single_resource_object_decorator.rb')
      end

      DocumentSingleResourceObjectDecorator.new(Article.new(1, 'My Article')).to_json
    end
  end
end
