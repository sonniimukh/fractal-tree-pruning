require 'test_helper'

class TreeServiceTest < ActiveSupport::TestCase

  test 'should return [] for an input tree of a wrong structure' do
    input = JSON.parse(File.read(Rails.root.join("test/fixtures/trees/incorrect-json.json" )))
    output = TreeService.prune(input, [1])
    assert_equal output, []
  end

  test 'should return [] if no indicator_ids provided' do
    input = JSON.parse(File.read(Rails.root.join("test/fixtures/trees/input.json" )))
    output = TreeService.prune(input)
    assert_equal output, []
  end

  test 'should only extract "Crude death rate"."total" for ids=[1] from sample dataset' do
    input = JSON.parse(File.read(Rails.root.join("test/fixtures/trees/input.json" )))
    output = TreeService.prune(input, [1])
    assert_equal output, JSON.parse('
      [
        {
          "id": 2, 
          "name": "Demographics", 
          "sub_themes": [
            {
              "categories": [
                {
                  "id": 11, 
                  "indicators": [
                    {
                      "id": 1, 
                      "name": "total"
                    }
                  ], 
                  "name": "Crude death rate", 
                  "unit": "(deaths per 1000 people)"
                }
              ], 
              "id": 4, 
              "name": "Births and Deaths"
            }
          ]
        }
      ]
    ')
  end

  test 'should keep all extra keys' do
    input = JSON.parse(File.read(Rails.root.join("test/fixtures/trees/extra-keys.json" )))
    output = TreeService.prune(input, [299])
    assert_equal output, JSON.parse('
      [
        {
          "id": 1, 
          "name": "Urban Extent", 
          "note": "EXTRA THEME KEY",
          "sub_themes": [
            {
              "id": 1, 
              "name": "Administrative",
              "note": "EXTRA SUB-THEME KEY",
              "categories": [
                {
                  "id": 1, 
                  "name": "Area", 
                  "unit": "(sq. km.)",
                  "note": "EXTRA CATEGORY KEY",
                  "indicators": [
                    {
                      "id": 299, 
                      "name": "Total",
                      "note": "EXTRA INDICATOR KEY"
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    ')
  end

  test 'should pass the example testing case' do
    input = JSON.parse(File.read(Rails.root.join("test/fixtures/trees/input.json" )))
    output = TreeService.prune(input, [31,32,1])
    assert_equal output, JSON.parse('
      [
        {
          "id": 2, 
          "name": "Demographics", 
          "sub_themes": [
            {
              "categories": [
                {
                  "id": 11, 
                  "indicators": [
                    {
                      "id": 1, 
                      "name": "total"
                    }
                  ], 
                  "name": "Crude death rate", 
                  "unit": "(deaths per 1000 people)"
                }
              ], 
              "id": 4, 
              "name": "Births and Deaths"
            }
          ]
        }, 
        {
          "id": 3, 
          "name": "Jobs", 
          "sub_themes": [
            {
              "categories": [
                {
                  "id": 23, 
                  "indicators": [
                    {
                      "id": 31, 
                      "name": "Total"
                    }, 
                    {
                      "id": 32, 
                      "name": "Female"
                    }
                  ], 
                  "name": "Unemployment rate, 15\u201324 years, usual", 
                  "unit": "(percent of labor force)"
                }
              ], 
              "id": 8, 
              "name": "Unemployment"
            }
          ]
        }
      ]
    ')
  end


end
