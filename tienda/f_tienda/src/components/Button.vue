<template>
  <button
    :type="type"
    :disabled="disabled"
    :class="computedClass"
    v-bind="$attrs"
  >
    <span v-if="hasIcon" class="-ml-1 mr-2 flex items-center">
      <slot name="icon" />
    </span>
    <span class="flex items-center gap-2">
      <slot />
    </span>
  </button>
</template>

<script setup>
import { computed, useAttrs } from 'vue';
import { useSlots } from 'vue';

const props = defineProps({
  variant: { type: String, default: 'primary' }, // primary | secondary | danger
  size: { type: String, default: 'md' }, // sm | md
  disabled: { type: Boolean, default: false },
  type: { type: String, default: 'button' },
});

const attrs = useAttrs();
const slots = useSlots();

const hasIcon = computed(() => {
  try {
    const nodes = slots.icon ? slots.icon() : [];
    return nodes.some(n => n != null);
  } catch (e) {
    return false;
  }
});

const computedClass = computed(() => {
  const base = ['btn'];
  // variant mapping aligns with existing CSS classes
  if (props.variant === 'primary') base.push('btn-primary');
  else if (props.variant === 'secondary') base.push('btn-secondary');
  else if (props.variant === 'danger') base.push('btn-danger');

  if (props.size === 'sm') base.push('btn-sm');

  // allow consumers to add extra utility classes via class attribute
  if (attrs.class) {
    // keep the attribute string; Vue will merge
  }

  return base.join(' ');
});
</script>

<style scoped>
/* Small tweaks to align with design language */
.btn { display: inline-flex; align-items: center; justify-content: center; }
</style>
