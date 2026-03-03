# frozen_string_literal: true

# Keep native function declarations split by domain so feature branches can
# add bindings with minimal merge conflicts.
require_relative 'functions/core'
require_relative 'functions/raster'
require_relative 'functions/text'
require_relative 'functions/effects'
require_relative 'functions/primitives'
require_relative 'functions/document_picture'
